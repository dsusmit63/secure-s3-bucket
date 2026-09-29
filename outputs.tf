
# ----------------------------------------
# S3 Outputs
# ----------------------------------------

output "customer_documents_bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.customer_documents_bucket.bucket
}

output "customer_documents_bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.customer_documents_bucket.arn
}

output "customer_documents_bucket_region" {
  description = "AWS region of the S3 bucket"
  value       = aws_s3_bucket.customer_documents_bucket.region
}

output "customer_documents_kms_key_arn" {
  description = "ARN of the KMS encryption key"
  value       = aws_kms_key.customer_documents_encryption_key.arn
}

# ----------------------------------------
# EC2 Outputs
# ----------------------------------------

output "customer_documents_ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.customer_documents_ec2.id
}

output "customer_documents_ec2_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.customer_documents_ec2.public_ip
}

output "customer_documents_ec2_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.customer_documents_ec2.private_ip
}

output "customer_documents_ec2_security_group_id" {
  description = "Security group ID attached to the EC2 instance"
  value       = aws_security_group.customer_documents_ec2_sg.id
}

output "customer_documents_ec2_ami_id" {
  description = "Ubuntu AMI ID used by the EC2 instance"
  value       = data.aws_ami.ubuntu.id
}

output "default_vpc_id" {
  description = "ID of the discovered default VPC"
  value       = data.aws_vpc.default.id
}

output "selected_public_subnet_id" {
  description = "ID of the selected default subnet"
  value       = data.aws_subnet.selected_public_subnet.id
}
