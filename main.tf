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
  cidr_blocks    = var.public_subnets
  azs            = var.azs
  is_public      = true
  route_table_id = module.vpc.public_route_table_id
  name_prefix    = "public-subnet"
}

module "private_subnets" {
  source         = "./modules/subnets"
  vpc_id         = module.vpc.vpc_id
  cidr_blocks    = var.private_subnets
  azs            = var.azs
  is_public      = false
  route_table_id = module.vpc.private_route_table_id
  name_prefix    = "private-subnet"
}
