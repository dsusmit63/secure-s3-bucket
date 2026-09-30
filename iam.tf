
# --------------------------------------------------
# 1. IAM Role for EC2
# --------------------------------------------------

resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  # Trust Policy for the role, means what is allowed to use this role
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          # This grants Amazon EC2 service explicit permission to assume this role
          Service = "ec2.amazonaws.com"
        }
        # This allows the EC2 service to call the AWS Security Token Service (STS) to get temporary credentials
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

resource "aws_iam_policy" "iam_policy" {
  name        = "${var.project_name}-iam-policy"
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

resource "aws_iam_role_policy_attachment" "role_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

# --------------------------------------------------
# 4. IAM Instance Profile
# --------------------------------------------------

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-ec2-instance-profile"

  role = aws_iam_role.ec2_role.name

  tags = {
    Name = "${var.project_name}-ec2-instance-profile"
  }
}

