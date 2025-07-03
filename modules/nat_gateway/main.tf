# NAT Gateway Module
# This module creates a NAT Gateway for outbound internet connectivity from private subnets

resource "aws_eip" "nat_gateway" {
  domain = "vpc"

  tags = {
    Name = "${var.vpc_name}-nat-gateway-eip"
  }

  # Ensure the internet gateway is created before the EIP
  depends_on = [var.internet_gateway_id]
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = var.public_subnet_id

  tags = {
    Name = "${var.vpc_name}-nat-gateway"
  }

  # Ensure the internet gateway is created before the NAT Gateway
  depends_on = [var.internet_gateway_id]
}
