module "s3_bucket" {
  source      = "./modules/s3_bucket"
  bucket_name = var.bucket_name
}

module "iam_github_actions" {
  source    = "./modules/iam_github_actions"
  repo_name = var.repo_name
}