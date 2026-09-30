
# ----------------------------------------
# Ubuntu 24.04 LTS AMI
# ----------------------------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

# ----------------------------------------
# Fetch Default VPC
# ----------------------------------------

data "aws_vpc" "default" {
  default = true
}

# ----------------------------------------
# Find AZs Supporting the Instance Type
# ----------------------------------------

data "aws_ec2_instance_type_offerings" "supported_azs" {
  filter {
    name   = "instance-type"
    values = [var.ec2_instance_type]
  }

  location_type = "availability-zone"
}

# ----------------------------------------
# Find Default Subnets in Supported AZs
# ----------------------------------------

data "aws_subnets" "default_public_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }

  filter {
    name   = "default-for-az"
    values = ["true"]
  }

  filter {
    name   = "availability-zone"
    values = data.aws_ec2_instance_type_offerings.supported_azs.locations
  }
}

# ----------------------------------------
# Select a Compatible Default Subnet
# ----------------------------------------

data "aws_subnet" "selected_public_subnet" {
  id = sort(data.aws_subnets.default_public_subnets.ids)[0]
}

# ----------------------------------------
# EC2 Security Group
# ----------------------------------------

resource "aws_security_group" "ec2_sg" {
  name        = "my-ec2-sg"
  description = "Security group for public EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow HTTP outbound"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Allow HTTPS outbound"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "my-ec2-sg"
  }
}

# ----------------------------------------
# EC2 Instance
# ----------------------------------------

resource "aws_instance" "my_ec2" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.ec2_instance_type

  subnet_id                   = data.aws_subnet.selected_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true

  key_name = var.key_pair_name

  # IAM instance profile for S3 access
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  # Require IMDSv2
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }

  # Encrypted root volume
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    encrypted             = true
    delete_on_termination = true
  }

  # Enable detailed monitoring
  monitoring = false

  # Protect against accidental Terraform destruction
  lifecycle {
    prevent_destroy = false
  }

  user_data = file("${path.module}/install-aws_cli.sh")

  tags = {
    Name = "my-ec2"
  }
}
