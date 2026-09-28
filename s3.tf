
#--------------------------------------------------
# Common Tags
#--------------------------------------------------

locals{
  common_tags = {
    Project = var.project_name
    Environment = var.environment
    ManagedBy = "Terraform"
  }
}

# --------------------------------------------------
# 1. AWS KMS Key
# --------------------------------------------------

resource "aws_kms_key" "customer_documents_encryption_key" {
  description             = "Customer managed KMS key for encrypting customer documents"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  lifecycle{
    prevent_destroy = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-bucket-kms-key"
}

# --------------------------------------------------
# 2. S3 Bucket
# --------------------------------------------------

resource "aws_s3_bucket" "customer_documents_bucket" {
  bucket        = var.bucket_name
  force_destroy = false
  
  lifecycle {
    prevent_destroy = true
  }
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-bucket"
  }
}

# --------------------------------------------------
# 3. S3 Block Public Access
# --------------------------------------------------

resource "aws_s3_bucket_public_access_block" "customer_documents_public_access_block" {
  bucket = aws_s3_bucket.customer_documents_bucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# --------------------------------------------------
# 4. S3 Object Ownership
# --------------------------------------------------

resource "aws_s3_bucket_ownership_controls" "customer_documents_ownership_controls" {
  bucket = aws_s3_bucket.customer_documents_bucket.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# --------------------------------------------------
# 5. S3 Versioning
# --------------------------------------------------

resource "aws_s3_bucket_versioning" "customer_documents_versioning" {
  bucket = aws_s3_bucket.customer_documents_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# --------------------------------------------------
# 6. S3 Server-Side Encryption
# --------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "customer_documents_encryption" {
  bucket = aws_s3_bucket.customer_documents_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.customer_documents_encryption_key.arn
    }

    bucket_key_enabled = true
  }
}

# --------------------------------------------------
# 7. S3 Bucket Policy - Enforce HTTPS
# --------------------------------------------------

resource "aws_s3_bucket_policy" "customer_documents_https_policy" {
  bucket = aws_s3_bucket.customer_documents_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"
        Action    = "s3:*"

        Resource = [
          aws_s3_bucket.customer_documents_bucket.arn,
          "${aws_s3_bucket.customer_documents_bucket.arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}
