# Terraform Bootstrap

Use this directory once if you want remote Terraform state for the AWS path.

## What it creates

- S3 bucket for `terraform.tfstate`
- DynamoDB table for state locking

## Usage

```bash
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply
```

Then uncomment the S3 backend block in `../environments/aws/backend.tf` and run
`terraform init -reconfigure` in the AWS environment.
