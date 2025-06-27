
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
  value       = module.routes.public_route_table_id
  description = "ID of the public route table"
}

output "private_route_table_id" {
  value       = module.routes.private_route_table_id
  description = "ID of the private route table"
}

output "public_subnet_ids" {
  value       = module.public_subnets.subnet_ids
  description = "IDs of the public subnets"
}

output "private_subnet_ids" {
  value       = module.private_subnets.subnet_ids
  description = "IDs of the private subnets"
}

output "ec2_private_k3s_server_instance_ids" {
  value       = module.ec2_private_k3s_server.instance_ids
  description = "ID of the EC2 instances for the k3s server"
}

output "ec2_private_k3s_agent_instance_ids" {
  value       = module.ec2_private_k3s_agent.instance_ids
  description = "IDs of the EC2 instances for the private k3s agents"
}
output "ec2_private_k3s_server_private_ips" {
  value       = module.ec2_private_k3s_server.private_ips
  description = "Private IP addresses of the EC2 instance for the k3s server"
}

output "ec2_private_k3s_agent_private_ips" {
  value       = module.ec2_private_k3s_agent.private_ips
  description = "Private IP addresses of the EC2 instances for the k3s agents"
}

output "bastion_instance_id" {
  value       = module.bastion.bastion_instance_id
  description = "ID of the bastion host instance"
}

output "bastion_public_ip" {
  value       = module.bastion.bastion_public_ip
  description = "Public IP address of the bastion host instance"
}

output "nat_gateway_id" {
  value       = module.nat_gateway.nat_gateway_id
  description = "ID of the NAT Gateway"
}

output "nat_gateway_public_ip" {
  value       = module.nat_gateway.nat_gateway_public_ip
  description = "Public IP address of the NAT Gateway"
}

output "calculated_availability_zones" {
  value       = local.availability_zones
  description = "Availability zones used for subnets"
}

output "calculated_private_subnets" {
  value       = local.private_subnets
  description = "CIDR blocks for private subnets (calculated or provided)"
}

output "calculated_public_subnets" {
  value       = local.public_subnets
  description = "CIDR blocks for public subnets (calculated or provided)"
}