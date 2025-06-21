module "s3_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = var.bucket_name
}

module "iam_github_actions" {
  source    = "./modules/iam_github_actions"
  repo_name = var.repo_name
}

module "vpc" {
  source   = "./modules/vpc"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
}

module "public_subnets" {
  source         = "./modules/subnets"
  vpc_id         = module.vpc.vpc_id
  cidr_blocks    = local.public_subnets
  azs            = local.availability_zones
  is_public      = true
  route_table_id = module.vpc.public_route_table_id
  name_prefix    = "public-subnet"
}

module "private_subnets" {
  source         = "./modules/subnets"
  vpc_id         = module.vpc.vpc_id
  cidr_blocks    = local.private_subnets
  azs            = local.availability_zones
  is_public      = false
  route_table_id = module.vpc.private_route_table_id
  name_prefix    = "private-subnet"
}

module "ec2_public" {
  source                 = "./modules/ec2"
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = module.public_subnets.subnet_ids
  instance_type          = var.ec2_instance_type
  key_name               = var.ec2_key_name
  name_prefix            = "public-ec2"
  is_public              = true
  vpc_cidr               = var.vpc_cidr
  enable_nat_server      = true
  private_route_table_id = module.vpc.private_route_table_id
}

module "ec2_private" {
  source        = "./modules/ec2"
  vpc_id        = module.vpc.vpc_id
  subnet_ids    = module.private_subnets.subnet_ids
  instance_type = var.ec2_instance_type
  key_name      = var.ec2_key_name
  name_prefix   = "private-ec2"
  is_public     = false
  vpc_cidr      = var.vpc_cidr
}

# Data source to get available availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Local values for computed subnets and AZs
locals {
  # Use provided AZs or get first 2 available ones
  availability_zones = length(var.azs) > 0 ? var.azs : slice(data.aws_availability_zones.available.names, 0, 2)

  # Calculate subnet CIDR blocks if not provided
  public_subnets = length(var.public_subnets) > 0 ? var.public_subnets : [
    for i in range(length(local.availability_zones)) :
    cidrsubnet(var.vpc_cidr, 8, i * 2)
  ]

  private_subnets = length(var.private_subnets) > 0 ? var.private_subnets : [
    for i in range(length(local.availability_zones)) :
    cidrsubnet(var.vpc_cidr, 8, i * 2 + 1)
  ]
}
