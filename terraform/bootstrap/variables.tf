variable "aws_region" {
  description = "AWS region for the Terraform backend resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used for tagging backend resources"
  type        = string
  default     = "sre-ecommerce"
}

variable "environment" {
  description = "Environment used for tagging backend resources"
  type        = string
  default     = "production"
}

variable "state_bucket_name" {
  description = "S3 bucket name used to store Terraform state"
  type        = string
  default     = "sre-capstone-tfstate"
}

variable "lock_table_name" {
  description = "DynamoDB table used for Terraform state locking"
  type        = string
  default     = "sre-capstone-tf-locks"
}
