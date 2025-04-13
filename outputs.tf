# =============================================================================
# VPC Output
# =============================================================================
# Output the ID of the created VPC
# This can be useful for referencing the VPC in other Terraform configurations
# or for use in scripts and documentation
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

# =============================================================================
# Public Subnet Outputs
# =============================================================================
# Output the IDs of the public subnets
# This can be useful for referencing the subnets in other Terraform configurations
# or for use in scripts and documentation
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.public[*].id
}

# =============================================================================
# Load Balancer Outputs
# =============================================================================
# Output the DNS name of the Application Load Balancer
# This is the endpoint you'll use to access your application
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

# Output the ARN of the Application Load Balancer
output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

# =============================================================================
# Auto Scaling Group Outputs
# =============================================================================
# Output the name of the Auto Scaling Group
output "asg_name" {
  description = "Name of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.name
}

# Output the ARN of the Auto Scaling Group
output "asg_arn" {
  description = "ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.main.arn
}

# Note: We can't output individual EC2 instance IDs or IPs directly from the ASG
# as these are managed dynamically. You can use AWS CLI or Console to view these. 