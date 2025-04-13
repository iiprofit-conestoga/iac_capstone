# =============================================================================
# AWS Provider Configuration
# =============================================================================
provider "aws" {
  region = var.aws_region
  # Using AWS CLI credentials
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "default"  # Change this if using a different profile
}

# =============================================================================
# S3 Bucket for Terraform State
# =============================================================================
# This bucket will store the Terraform state file, which tracks the current
# state of your infrastructure. Versioning is enabled to maintain a history
# of state changes.
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  tags = {
    Name        = "Terraform State"
    Environment = "Development"
  }
}

# =============================================================================
# S3 Bucket Versioning
# =============================================================================
# Enable versioning on the S3 bucket to track state file history
resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

# =============================================================================
# VPC Configuration
# =============================================================================
# Create a VPC to isolate our resources and provide network security
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true  # Enable DNS hostnames for the VPC
  enable_dns_support   = true  # Enable DNS support for the VPC

  tags = {
    Name = "Main VPC"
  }
}

# =============================================================================
# Public Subnet Configuration
# =============================================================================
# Create public subnets within the VPC for resources that need internet access
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

# =============================================================================
# Internet Gateway Configuration
# =============================================================================
# Create an Internet Gateway to allow resources in the public subnet
# to access the internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main IGW"
  }
}

# =============================================================================
# Route Table Configuration
# =============================================================================
# Create a route table for the public subnet with a route to the internet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"  # Route all traffic to the internet
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# =============================================================================
# Route Table Association
# =============================================================================
# Associate the public subnets with the public route table
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# =============================================================================
# Security Group for ALB
# =============================================================================
resource "aws_security_group" "alb_sg" {
  name        = "ALB Security Group"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB Security Group"
  }
}

# =============================================================================
# Security Group for EC2 instances
# =============================================================================
resource "aws_security_group" "ec2_sg" {
  name        = "EC2 Security Group"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "EC2 Security Group"
  }
}

# =============================================================================
# Application Load Balancer
# =============================================================================
resource "aws_lb" "main" {
  name               = "main-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "Main ALB"
  }
}

# =============================================================================
# ALB Target Group
# =============================================================================
resource "aws_lb_target_group" "main" {
  name     = "main-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    timeout             = 5
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    unhealthy_threshold = 2
  }
}

# =============================================================================
# ALB Listener
# =============================================================================
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# =============================================================================
# Launch Template
# =============================================================================
resource "aws_launch_template" "main" {
  name_prefix   = "main-lt"
  image_id      = var.ami_id
  instance_type = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups            = [aws_security_group.ec2_sg.id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Web Server"
    }
  }
}

# =============================================================================
# Auto Scaling Group
# =============================================================================
resource "aws_autoscaling_group" "main" {
  name                = "main-asg"
  desired_capacity    = 2
  max_size           = 4
  min_size           = 1
  target_group_arns  = [aws_lb_target_group.main.arn]
  vpc_zone_identifier = aws_subnet.public[*].id

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value              = "Web Server"
    propagate_at_launch = true
  }
}

# =============================================================================
# Data source for availability zones
# =============================================================================
data "aws_availability_zones" "available" {
  state = "available"
} 