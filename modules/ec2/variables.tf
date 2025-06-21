variable "vpc_id" {
  type        = string
  description = "ID of the VPC where the EC2 instances will be created"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs where EC2 instances will be created"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  type        = string
  description = "Name of the AWS key pair to use for EC2 instances"
  default     = null
}

variable "name_prefix" {
  type        = string
  description = "Prefix for naming resources"
  default     = "ec2-public"
}

variable "is_public" {
  type        = bool
  description = "Whether these instances should be public (with public IP) or private"
  default     = true
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block for security group rules"
  default     = null
}

variable "enable_nat_server" {
  type        = bool
  description = "Whether to configure one of the instances as NAT server"
  default     = false
}

variable "private_route_table_id" {
  type        = string
  description = "ID of private route table for NAT server route (required if enable_nat_server is true)"
  default     = null
}
