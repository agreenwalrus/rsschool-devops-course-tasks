variable "vpc_name" {
  description = "Name tag for the VPC"
  type        = string
}

variable "public_subnet_id" {
  description = "ID of the public subnet where NAT Gateway will be placed"
  type        = string
}

variable "internet_gateway_id" {
  description = "ID of the Internet Gateway (for dependency)"
  type        = string
}
