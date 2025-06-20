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
  description = "List of CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"
  default     = ["10.0.100.0/24", "10.0.101.0/24"]
}

variable "azs" {
  type        = list(string)
  description = "List of availability zones to create subnets in. The number of AZs should match the number of CIDR blocks."
  default     = ["eu-west-1a", "eu-west-1b"]
}
