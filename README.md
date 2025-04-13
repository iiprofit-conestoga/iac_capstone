# AWS Infrastructure with Terraform

## Overview
This project creates a scalable AWS infrastructure using Terraform, including:
- S3 bucket for Terraform state
- VPC with multiple public subnets across availability zones
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG) with multiple EC2 instances
- Security groups for ALB and EC2 instances

## Prerequisites
- AWS account
- Terraform installed
- AWS CLI installed and configured

## AWS CLI Setup Instructions

1. **Install AWS CLI**
   ```bash
   # Using Homebrew
   brew install awscli
   ```

2. **Configure AWS CLI**
   ```bash
   aws configure
   ```
   You will be prompted to enter:
   - AWS Access Key ID
   - AWS Secret Access Key
   - Default region name (e.g., us-east-1)
   - Default output format (json)

3. **Verify AWS CLI Configuration**
   ```bash
   aws sts get-caller-identity
   ```

## Terraform Setup Instructions

1. **Install Terraform**
   ```bash
   # Using Homebrew
   brew tap hashicorp/tap
   brew install hashicorp/tap/terraform
   ```

2. **Update Configuration**
   - Edit `terraform.tfvars` and update:
     - `state_bucket_name` to a unique name
     - `aws_region` to your preferred region
     - `vpc_cidr` if you want a different VPC CIDR block
     - `ami_id` to match your region's Amazon Linux 2 AMI
     - `instance_type` if you want a different instance size
   - Edit `backend.tf` and update:
     - `bucket` to match the same unique name you used in terraform.tfvars
     - `region` to match your AWS region

3. **Initialize Terraform**
   ```bash
   terraform init
   ```

4. **Review the Plan**
   ```bash
   terraform plan
   ```

5. **Apply the Configuration**
   ```bash
   terraform apply
   ```

## Cleanup Instructions

To remove all created resources, follow these steps:

1. **Destroy the Infrastructure**
   ```bash
   terraform destroy
   ```
   This command will:
   - Show you a plan of what will be destroyed
   - Ask for confirmation before proceeding
   - Remove all resources created by Terraform

2. **Verify Resources are Removed**
   ```bash
   # Check if EC2 instances are removed
   aws ec2 describe-instances --filters "Name=tag:Name,Values=Web Server"
   
   # Check if VPC is removed
   aws ec2 describe-vpcs --filters "Name=tag:Name,Values=Main VPC"
   
   # Check if S3 bucket is removed
   aws s3 ls s3://your-unique-terraform-state-bucket
   
   # Check if ALB is removed
   aws elbv2 describe-load-balancers --names main-alb
   ```

3. **Clean Up Local Terraform Files (Optional)**
   ```bash
   # Remove local state file if it exists
   rm -f terraform.tfstate
   
   # Remove local state backup if it exists
   rm -f terraform.tfstate.backup
   
   # Remove .terraform directory
   rm -rf .terraform
   ```

4. **Clean Up S3 Bucket (if not automatically removed)**
   ```bash
   # If the S3 bucket still exists and contains objects
   aws s3 rm s3://your-unique-terraform-state-bucket --recursive
   
   # Delete the bucket itself
   aws s3 rb s3://your-unique-terraform-state-bucket
   ```

## Configuration Files Explained

1. **variables.tf**
   - Defines all variables used in the project
   - Includes `state_bucket_name`, `aws_region`, `vpc_cidr`, `ami_id`, and `instance_type`

2. **terraform.tfvars**
   - Contains the actual values for variables
   - Set your unique bucket name here: `state_bucket_name = "your-unique-name"`
   - Configure other variables like region, VPC CIDR, AMI ID, and instance type

3. **backend.tf**
   - Configures where Terraform stores its state
   - **IMPORTANT**: The backend configuration must use hardcoded values, not variables
   - You must manually update the bucket name and region to match your terraform.tfvars

4. **main.tf**
   - Contains the main infrastructure configuration
   - Creates the S3 bucket, VPC, subnets, ALB, and ASG

## Resources Created
- S3 bucket for Terraform state
- VPC with multiple public subnets across availability zones
- Internet Gateway
- Route Tables
- Security Groups for ALB and EC2 instances
- Application Load Balancer (ALB)
- ALB Target Group
- ALB Listener
- Launch Template for EC2 instances
- Auto Scaling Group (ASG) with multiple EC2 instances

## Load Balancer and Auto Scaling Configuration

### Application Load Balancer (ALB)
- Distributes incoming traffic across multiple EC2 instances
- Configured with health checks to ensure only healthy instances receive traffic
- Listens on port 80 for HTTP traffic
- Placed in public subnets for internet accessibility

### Auto Scaling Group (ASG)
- Maintains a desired number of EC2 instances (default: 2)
- Can scale up to 4 instances during high load
- Maintains at least 1 instance during low load
- Automatically replaces failed instances
- Uses a launch template to ensure consistent instance configuration

### High Availability
- Resources are distributed across multiple availability zones
- If one AZ fails, the application continues to run in other AZs
- Load balancer health checks ensure traffic is only sent to healthy instances

## Outputs
- ALB DNS Name (used to access your application)
- VPC ID
- Public Subnet IDs
- EC2 Instance IDs (via AWS Console or CLI)

## Accessing Your Application
After applying the Terraform configuration, you can access your application using the ALB DNS name that is output by Terraform. The DNS name will look something like:
```
main-alb-1234567890.us-east-1.elb.amazonaws.com
```

## Important Notes
1. Make sure to use a unique S3 bucket name as they must be globally unique
2. The AMI ID might need to be updated based on your region
3. Keep your AWS credentials secure and never commit them to version control
4. The `terraform.tfvars` file might contain sensitive information, so consider adding it to `.gitignore`
5. Ensure your AWS CLI credentials have the necessary permissions to create all resources
6. Always run `terraform destroy` when you're done to avoid unnecessary AWS charges
7. **IMPORTANT**: The backend configuration in `backend.tf` must use hardcoded values, not variables
8. The Auto Scaling Group will maintain the desired number of instances, which may incur costs
9. Consider setting up CloudWatch alarms to monitor your ASG and ALB 