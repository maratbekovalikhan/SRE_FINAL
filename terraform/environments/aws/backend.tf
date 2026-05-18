# Remote state with S3 backend.
# Uncomment after creating the S3 bucket and DynamoDB table
# (see terraform/bootstrap/ for provisioning these resources).

# terraform {
#   backend "s3" {
#     bucket         = "sre-capstone-tfstate"
#     key            = "aws/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "sre-capstone-tf-locks"
#   }
# }

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
