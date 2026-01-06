resource "random_uuid" "bucket_suffix" {}

resource "aws_s3_bucket" "webapp_files" {
  bucket        = "csye6225-s3-${random_uuid.bucket_suffix.result}"
  force_destroy = true
  tags = {
    Name        = "CSYE6225 Assignment S3"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.webapp_files.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.webapp_files.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_kms_key.arn
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle" {
  bucket = aws_s3_bucket.webapp_files.id

  rule {
    id     = "transition-to-ia"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.webapp_files.bucket
}
