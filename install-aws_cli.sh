#!/bin/bash

set -e

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
