# Secure an S3 Bucket using Terraform
**Objective -** Create a secure S3 bucket for sensitive customer documents using terraform.
## Pre-requisites 
### Install AWS CLI
```bash
sudo apt update
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install
```
### Install Terraform
```bash
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```
### Create an IAM identity with permissions to create S3 buckets and KMS keys
```bash
aws configure [Put your access key ID, secret access key ID of IAM identity]
```
### Verify your setup
```bash
aws --version
terraform --version
aws sts get-caller-identity
```
