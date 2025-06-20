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