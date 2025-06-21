# This module creates EC2 instances in specified subnets with optional NAT server functionality.
# It supports both public and private subnets, with security groups configured for SSH, HTTP, and HTTPS access.

# Data source to get the latest Amazon Linux 2 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name_prefix = "${var.name_prefix}-sg"
  vpc_id      = var.vpc_id
  description = var.is_public ? "Security group for EC2 instances in public subnets" : "Security group for EC2 instances in private subnets"

  # SSH access - from anywhere for public, from VPC for private
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.is_public ? ["0.0.0.0/0"] : [var.vpc_cidr]
    description = "SSH access"
  }

  # HTTP access - from anywhere for public, from VPC for private
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.is_public ? ["0.0.0.0/0"] : [var.vpc_cidr]
    description = "HTTP access"
  }

  # HTTPS access - from anywhere for public, from VPC for private
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.is_public ? ["0.0.0.0/0"] : [var.vpc_cidr]
    description = "HTTPS access"
  }

  # NAT traffic - allow all traffic from private subnets if this is a NAT server
  dynamic "ingress" {
    for_each = var.enable_nat_server && var.is_public ? [1] : []
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = [var.vpc_cidr]
      description = "Allow all traffic from VPC for NAT functionality"
    }
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "All outbound traffic"
  }

  tags = {
    Name = "${var.name_prefix}-security-group"
  }
}

# EC2 instances
resource "aws_instance" "ec2" {
  count                       = length(var.subnet_ids)
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_ids[count.index]
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = var.is_public
  key_name                    = var.key_name
  source_dest_check           = var.enable_nat_server && count.index == 0 ? false : true

  user_data = base64encode(templatefile("${path.module}/user_data_${var.enable_nat_server && count.index == 0 ? "nat" : "default"}.sh", {
    instance_name = "${var.name_prefix}-${count.index + 1}"
    instance_type = var.is_public ? "public" : "private"
  }))

  tags = {
    Name = "${var.name_prefix}-${count.index + 1}"
    Type = var.enable_nat_server && count.index == 0 ? "nat-server" : (var.is_public ? "public" : "private")
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Route for private subnets to use first EC2 instance as NAT server
resource "aws_route" "private_nat" {
  count                  = var.enable_nat_server ? 1 : 0
  route_table_id         = var.private_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.ec2[0].primary_network_interface_id
}
