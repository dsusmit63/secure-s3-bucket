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
### Run Terraform
```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply -auto-approve
terraform output
```
### Connect to your Instance using your private key
```bash
ssh -i my-ec2-key.pem ubuntu@<EC2_PUBLIC_IP>
```

### Verify the Operating System
```bash
cat /etc/os-release
```
You should see Ubuntu 24.04 LTS details.

### Verify IAM Role
On the EC2 instance, run:
```bash
aws sts get-caller-identity
```
This shows the assumed IAM role identity.

### List Buckets (Account Level)
```bash
aws s3 ls
```
### List Bucket Objects (Bucket Level)
```bash
aws s3 ls s3://my-secure-customer-documents-unique-12345
```
### Test File upload and download
Create a test file:
```bash
echo "This is a test document for S3" > test.txt
```
Upload it:
```bash
aws s3 cp test.txt s3://my-secure-customer-documents-unique-12345/test.txt
```
Verify the uploaded object:
```bash
aws s3 ls s3://my-secure-customer-documents-unique-12345/
```
Download it: 
```bash
aws s3 cp s3://my-secure-customer-documents-unique-12345/test.txt downloaded.txt
```
Verify:
```bash
cat downloaded.txt
```

### Check Versioning
Check if versioning is enabled or not:
```bash
aws s3api get-bucket-versioning --bucket my-secure-customer-documents-unique-12345
```
After getting confirmed, modify the downloaded test.txt and reupload it. Then check:
```bash
aws s3api list-object-versions --bucket my-secure-customer-documents-unique-12345 --prefix test.txt
```
Cleanup the output: 
```bash
aws s3api list-object-versions --bucket my-secure-customer-documents-unique-12345 --prefix test.txt --query "Versions[].{Version:VersionId, LastModified:LastModified, Latest:IsLatest}" --output table
```
Download the older version to compare:
```bash
aws s3api get-object --bucket my-secure-customer-documents-unique-12345 --key test.txt --version-id "PASTE_OLD_VERSION_ID_HERE" test_v1.txt
```
