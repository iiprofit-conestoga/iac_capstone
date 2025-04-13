# =============================================================================
# AWS Region Configuration
# =============================================================================
# The AWS region where resources will be created
aws_region = "us-east-1"  # US East (N. Virginia)

# =============================================================================
# S3 Bucket Configuration
# =============================================================================
# The name of the S3 bucket that will store the Terraform state file
# IMPORTANT: This bucket name must be globally unique across all AWS accounts
# Change this to a unique name before applying
state_bucket_name = "ksolanki6269-iac"

# =============================================================================
# EC2 Instance Configuration
# =============================================================================
# The instance type for the EC2 instance
instance_type = "t2.micro"  # Free tier eligible instance type

# The ID of the Amazon Machine Image to use for the EC2 instance
# This is an Amazon Linux 2 AMI - you may need to update this based on your region
ami_id = "ami-00a929b66ed6e0de6"  # Amazon Linux 2023 AMI for us-east-1 