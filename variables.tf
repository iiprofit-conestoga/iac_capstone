# =============================================================================
# AWS Region Variable
# =============================================================================
# The AWS region where resources will be created
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"  # Default to US East (N. Virginia)
}

# =============================================================================
# AWS Profile Variable
# =============================================================================
# The AWS CLI profile to use for authentication
variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "default"  # Default to the default profile
}

# =============================================================================
# S3 Bucket Name Variable
# =============================================================================
# The name of the S3 bucket that will store the Terraform state file
# This bucket name must be globally unique across all AWS accounts
variable "state_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  # No default value - must be provided in terraform.tfvars
}

# =============================================================================
# VPC CIDR Block Variable
# =============================================================================
# The CIDR block for the VPC (e.g., 10.0.0.0/16)
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"  # Default to a private IP range
}

# =============================================================================
# Subnet CIDR Block Variable
# =============================================================================
# The CIDR block for the public subnet (must be within the VPC CIDR)
variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
  default     = "10.0.1.0/24"  # Default to a subset of the VPC CIDR
}

# =============================================================================
# Availability Zone Variable
# =============================================================================
# The availability zone where the subnet will be created
variable "availability_zone" {
  description = "Availability zone for subnet"
  type        = string
  default     = "us-east-1a"  # Default to the first AZ in the region
}

# =============================================================================
# EC2 Instance Type Variable
# =============================================================================
# The instance type for the EC2 instance (e.g., t2.micro)
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"  # Default to t2.micro (free tier eligible)
}

# =============================================================================
# AMI ID Variable
# =============================================================================
# The ID of the Amazon Machine Image to use for the EC2 instance
variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  # No default value - must be provided in terraform.tfvars
} 