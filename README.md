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

### Verify Bucket Versioning
Check if versioning is enabled or not:
```bash
aws s3api get-bucket-versioning --bucket my-secure-customer-documents-unique-12345
```
> What it verifies: S3 versioning is enabled, allowing previous object versions to be retained when an object is overwritten
or deleted.

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

### Delete

#### Soft Deletion: 
When you run standard delete command on a versioned bucket, AWS does not erase the file. Instead it adds a Delete Marker on top of it. Any normal request to read the file acts like the file is gone.
```bash
aws s3 rm s3://my-secure-customer-documents-unique-12345/test.txt
or,
aws s3api delete-object --bucket my-secure-customer-documents-unique-12345 --key test.txt
```
Verify:
```bash
aws s3 cp s3://my-secure-customer-documents-unique-12345/test.txt .
```
S3 will return 404 Not Found error. To the outside world, the file is deleted.

Now to make the file active again, you simply need to permanently delete the Delete Marker itself: 

Find the version ID of the Delete Marker:
```bash
aws s3api list-object-versions \
  --bucket my-secure-customer-documents-unique-12345 \
  --prefix test.txt
```

Delete the Delete Marker:
```bash
aws s3api delete-object \
  --bucket my-secure-customer-documents-unique-12345 \
  --key test.txt \
  --version-id <DELETE_MARKER_VERSION_ID>
```
List all hidden versions & markers:
```bash
aws s3api list-object-versions --bucket my-secure-customer-documents-unique-12345 --prefix test.txt
```

#### Permanent Deletion:
```bash
aws s3api delete-object \
  --bucket my-secure-customer-documents-unique-12345 \
  --key test.txt \
  --version-id <YOUR_DATA_VERSION_ID>
```
Purge everything (all versions of a file) at once:
```bash
aws s3api delete-objects \
  --bucket my-secure-customer-documents-unique-12345 \
  --delete "$(aws s3api list-object-versions --bucket my-secure-customer-documents-unique-12345 --prefix test.txt --output json | jq '{Objects: [.Versions[], .DeleteMarkers[]] | map({Key: .Key, VersionId: .VersionId})}')"
```

### Verify KMS Encryption
```bash
aws s3api head-object \--bucket my-secure-customer-documents-unique-12345 \--key test.txt
```
Look for "ServerSideEncryption":"aws:kms", "SSEKMSKeyId":"arn:aws:kms:us-east-1:..." fields. It confirms whether the object in S3 is encrypted using your configured AWS KMS key.

### Verify the Lifecycle Configuration
```bash
aws s3api get-bucket-lifecycle-configuration \--bucket my-secure-customer-documents-unique-12345
```

### Verify S3 Block Public Access
```bash
aws s3api get-public-access-block \--bucket my-secure-customer-documents-unique-12345
```
What this verifies: All four S3 Block Public Access Block settings are enabled.

### Verify Bucket Ownership Control
```bash
aws s3api get-bucket-ownership-controls \--bucket my-secure-customer-documents-unique-12345
```
This confirms that the bucket owner owns uploaded objects.
