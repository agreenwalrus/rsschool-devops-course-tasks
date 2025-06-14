# rsschool-devops-course-tasks
RS AWS DevOps 2025Q2

# Terraform AWS Infrastructure Setup

This project contains Terraform code and GitHub Actions workflows for deploying AWS infrastructure with remote state stored in S3 and CI/CD automation.

## Prerequisites
- AWS account with permissions to create IAM roles, S3 buckets, and other resources
- [Terraform](https://www.terraform.io/) >= 1.0.0
- AWS S3 bucket for storing Terraform state
- GitHub repository with the following secrets configured:
  - `AWS_ACCOUNT_ID`: Your AWS account ID
  - `TERRAFORM_STATE_BUCKET`: Name of the S3 bucket for Terraform state

## Project Structure
- `provider.tf` — Provider and backend configuration
- `variables.tf` — Input variables (region, bucket name, etc.)
- `terraform.tfvars.example` — Example values for variables for local run
- `s3_bucket.tf` — S3 bucket resource for state (optional, if you want to create it via Terraform)
- `iam_github_actions.tf` — IAM role and OIDC provider for GitHub Actions
- `.github/workflows/terraform.yaml` — CI/CD workflow for Terraform

## Terraform State Management
Terraform uses a state file to keep track of resources it manages. In this project, the state is stored remotely in an S3 bucket. State locking is enabled by default using the S3 backend to prevent concurrent modifications.


- The backend configuration is in `provider.tf`.
- Extra S3 bucket is defined in `s3_bucket.tf`.
- The state file path is typically `state/terraform.tfstate` in S3 bucket.

## AWS Configuration
Before running Terraform, configure your AWS credentials so Terraform and the GitHub Actions workflow can authenticate to AWS. You can do this in one of the following ways:

### Option 1: Using AWS CLI
If you have the AWS CLI installed, run:
```sh
aws configure
```
This will prompt you for your AWS Access Key ID, Secret Access Key, region, and output format.

### Option 2: Using Environment Variables
Set the following environment variables in your shell:
```sh
$env:AWS_ACCESS_KEY_ID="<your-access-key-id>"
$env:AWS_SECRET_ACCESS_KEY="<your-secret-access-key>"
$env:AWS_DEFAULT_REGION="eu-west-1"
```
Replace the values with your actual credentials and preferred region.

## Usage

### 1. Configure AWS and S3
- Create an S3 bucket for Terraform state.
- Enable versioning and encryption on the bucket for best practices.

### 2. Set up GitHub Secrets
In your repository settings, add:
- `AWS_ACCOUNT_ID` — your AWS account ID
- `TERRAFORM_STATE_BUCKET` — the name of S3 bucket for state
- `EXTRA_BUCKET` -  the name of extra S3 bucket (as an example)

### 3. Configure IAM for GitHub Actions
- Deploy the resources in `iam_github_actions.tf` to create an OIDC provider and IAM role for GitHub Actions.
- The trust policy allows the repo to assume the role via OIDC.

### 4. Initialize and Apply Terraform Locally
- Create state.config file based on state.config.example.
- Create terraform.tfvars file based on terraform.tfvars.example to provide variable values.
```sh
terraform init terraform init -backend-config="./state.config"
terraform plan
terraform apply
```

### 5. CI/CD with GitHub Actions
- On every push or pull request to `main`, the workflow in `.github/workflows/terraform.yaml` will:
  - Check Terraform formatting
  - Run `terraform plan`
  - On push to `main`, run `terraform apply`
- The workflow uses OIDC to authenticate to AWS securely.

## Variables
- `aws_region` — AWS region (default: `eu-west-1`)
- `bucket_name` — S3 bucket
