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