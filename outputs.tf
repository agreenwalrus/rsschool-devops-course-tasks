output "github_actions_role_arn" {
  value       = module.iam_github_actions.github_actions_role_arn
  description = "ARN of the IAM role for GitHub Actions."
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "ID of the VPC"
}

output "vpc_cidr_block" {
  value       = module.vpc.vpc_cidr_block
  description = "CIDR block of the VPC"
}

output "internet_gateway_id" {
  value       = module.vpc.internet_gateway_id
  description = "ID of the Internet Gateway"
}

output "public_route_table_id" {
  value       = module.vpc.public_route_table_id
  description = "ID of the public route table"
}
