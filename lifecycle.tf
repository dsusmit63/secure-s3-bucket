resource "aws_s3_bucket_lifecycle_configuration" "customer_documents_lifecycle" {
  bucket = aws_s3_bucket.customer_documents_bucket.id

  rule {
    id     = "manage-old-versions"
    status = "Enabled"

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 90
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
