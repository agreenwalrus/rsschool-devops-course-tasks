variable "aws_region" {
  type        = string
  description = "The AWS region to deploy resources in."
}

variable "bucket_name" {
  type        = string
  description = "The name of the S3 bucket."
}

variable "repo_name" {
  type        = string
  description = "The GitHub repository name for OIDC trust (format: owner/repo)."
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  type        = string
  description = "Name of the VPC"
  default     = "main-vpc"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets. If not provided, will be calculated automatically."
  default     = []
}

variable "private_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets. If not provided, will be calculated automatically."
  default     = []
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones to create subnets in. If not provided, will use available AZs in the region."
  default     = []
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type for public instances"
  default     = "t2.micro"
}

variable "ec2_key_name" {
  type        = string
  description = "Name of the AWS key pair to use for EC2 instances (optional)"
  default     = null
}
