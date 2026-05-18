variable "app_image" {
  description = "Docker image for the task-api application"
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
