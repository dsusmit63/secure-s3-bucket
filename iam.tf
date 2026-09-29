
# --------------------------------------------------
# 1. IAM Role for EC2
# --------------------------------------------------

resource "aws_iam_role" "customer_documents_ec2_role" {
  name = "${var.project_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-ec2-role"
  }
}

# --------------------------------------------------
# 2. IAM Policy for S3 and KMS Access
# --------------------------------------------------

resource "aws_iam_policy" "customer_documents_s3_policy" {
  name        = "${var.project_name}-s3-policy"
  description = "Allow EC2 to access customer documents in S3 using KMS"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "AllowBucketListing"
        Effect = "Allow"

        Action = [
          "s3:ListBucket"
        ]

        Resource = aws_s3_bucket.customer_documents_bucket.arn
      },
      {
        Sid    = "AllowObjectReadWrite"
        Effect = "Allow"

        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]

        Resource = "${aws_s3_bucket.customer_documents_bucket.arn}/*"
      },
      {
        Sid    = "AllowKMSForS3"
        Effect = "Allow"

        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:GenerateDataKey",
          "kms:DescribeKey"
        ]

        Resource = aws_kms_key.customer_documents_encryption_key.arn
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-s3-policy"
  }
}

# --------------------------------------------------
# 3. Attach IAM Policy to Role
# --------------------------------------------------

resource "aws_iam_role_policy_attachment" "customer_documents_policy_attachment" {
  role       = aws_iam_role.customer_documents_ec2_role.name
  policy_arn = aws_iam_policy.customer_documents_s3_policy.arn
}

# --------------------------------------------------
# 4. IAM Instance Profile
# --------------------------------------------------

resource "aws_iam_instance_profile" "customer_documents_instance_profile" {
  name = "${var.project_name}-instance-profile"

  role = aws_iam_role.customer_documents_ec2_role.name

  tags = {
    Name = "${var.project_name}-instance-profile"
  }
}

