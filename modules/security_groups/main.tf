# Security group for NAT instance
resource "aws_security_group" "nat" {
  name        = "${var.vpc_name}-nat-sg"
  description = "Security group for NAT instance"
  vpc_id      = var.vpc_id

  # Allow all traffic from private subnets
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.private_subnet_cidrs
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-nat-sg"
  }
}

# Security group for bastion host
resource "aws_security_group" "bastion" {
  name        = "${var.vpc_name}-bastion-sg"
  description = "Security group for bastion host"
  vpc_id      = var.vpc_id

  # Allow SSH from specific IP (should be restricted in production)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.bastion_allowed_cidr
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-bastion-sg"
  }
}

# Security group for private instances
resource "aws_security_group" "ssh_from_bastion" {
  name        = "${var.vpc_name}-ssh-from-bastion-sg"
  description = "Security group for private instances allowing SSH from bastion host"
  vpc_id      = var.vpc_id

  # Allow SSH from bastion only
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-ssh-from-bastion-sg"
  }
}

# Security group for public EC2 instances (например, web-серверы)
resource "aws_security_group" "web" {
  name        = "${var.vpc_name}-web-sg"
  description = "Security group for public EC2 instances (web, etc)"
  vpc_id      = var.vpc_id

  # Allow HTTP and HTTPS from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-web-sg"
  }
}

# Security group for inter-subnet communication
resource "aws_security_group" "inter_subnet" {
  name        = "${var.vpc_name}-inter-subnet-sg"
  description = "Security group allowing communication between all subnets within VPC"
  vpc_id      = var.vpc_id

  # Allow all traffic from VPC CIDR (all subnets)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vpc_name}-inter-subnet-sg"
  }
}

