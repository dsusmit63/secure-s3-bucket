
output "customer_documents_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.customer_documents_bucket.bucket
}

output "customer_documents_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.customer_documents_bucket.arn
}

output "customer_documents_kms_key_arn" {
  description = "ARN of the KMS encryption key"
  value       = aws_kms_key.customer_documents_encryption_key.arn
}

output "customer_documents_bucket_region" {
  description = "AWS region of the S3 bucket"
  value       = aws_s3_bucket.customer_documents_bucket.region
}
