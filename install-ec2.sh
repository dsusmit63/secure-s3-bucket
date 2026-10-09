#!/bin/bash

set -e

echo "===== EC2 Bootstrap started ====="

# Install AWS CLI

# Update packages
apt-get update -y

# Install required packages
apt-get install -y curl unzip

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o "/tmp/awscliv2.zip"

unzip -q /tmp/awscliv2.zip -d /tmp

/tmp/aws/install

# Verify installation
aws --version


# Install CloudWatch Agent

wget https://amazoncloudwatch-agent.s3.amazonaws.com/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb

sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

echo "CloudWatch Agent installed successfully"

# --------------------------------------------------
# Create CloudWatch Agent configuration
# --------------------------------------------------

cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'EOF'
{
  "metrics": {
    "namespace": "Custom/EC2",
    "append_dimensions": {
       "InstanceId": "${aws:InstanceId}"
     },
    "metrics_collected": {
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "resources": [
          "/"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOF

echo "CloudWatch Agent configuration created"

# --------------------------------------------------
# Start CloudWatch Agent with configuration
# --------------------------------------------------

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

echo "===== CloudWatch Agent started successfully ====="

# --------------------------------------------------
# Show status
# --------------------------------------------------

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a status
