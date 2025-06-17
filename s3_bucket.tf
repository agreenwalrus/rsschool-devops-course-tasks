resource "aws_s3_bucket" "extra_bucket" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_s3_bucket_versioning" "extra_bucket_versioning" {
  bucket = aws_s3_bucket.extra_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}