# =============================================================================
# Terraform Backend Configuration
# =============================================================================
# This block configures where Terraform stores its state file.
# By default, Terraform stores state locally, but for team collaboration
# and safety, it's better to store it remotely in an S3 bucket.
terraform {
  backend "s3" {
    # The name of the S3 bucket to store the state file
    # This should match the bucket created in main.tf
    bucket = "ksolanki6269-iac-backup"
    
    # The path within the bucket to store the state file
    key    = "terraform.tfstate"
    
    # The AWS region where the bucket is located
    region = "us-east-1"
  }
} 