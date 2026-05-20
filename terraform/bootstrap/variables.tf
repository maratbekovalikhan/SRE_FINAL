variable "aws_region" {
  description = "AWS region for Terraform state resources"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "S3 bucket used to store Terraform state"
  type        = string
  default     = "sre-capstone-tfstate"
}

variable "lock_table_name" {
  description = "DynamoDB table used for Terraform state locking"
  type        = string
  default     = "sre-capstone-tf-locks"
}
