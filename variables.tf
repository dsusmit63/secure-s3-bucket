
# ----------------------------------------
# General Variables
# ----------------------------------------

variable "aws_region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "secure-s3-bucket"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

# ----------------------------------------
# S3 Variables
# ----------------------------------------

variable "bucket_name" {
  description = "Globally unique S3 bucket name"
  type        = string

  validation {
    condition = (
      length(var.bucket_name) >= 3 &&
      length(var.bucket_name) <= 63 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    )
    error_message = "Bucket name must be 3-63 characters, use lowercase letters, numbers, and hyphens, and start and end with a letter or number."
  }
}

# ----------------------------------------
# EC2 Variables
# ----------------------------------------

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Existing AWS EC2 key pair name"
  type        = string
}

# ----------------------------------------
# Email Variable
# ----------------------------------------

variable "notification_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  default     = "dsusmit63@gmail.com"
}
# ---------------------------------------
# Phone Variable
# ---------------------------------------

variable "notification_phone" {
  description = "Phone Number for Cloudwatch alarm notifications"
  type      = string
  sensitive = true
}

