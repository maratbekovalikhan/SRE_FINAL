variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "sre-capstone"
}

variable "app_image" {
  description = "Docker image for the task-api (ECR URL)"
  type        = string
}

variable "database_password" {
  description = "Password for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
}
