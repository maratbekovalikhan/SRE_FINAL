variable "namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "task-api"
}

variable "app_image" {
  description = "Docker image for the task-api application"
  type        = string
}

variable "app_replicas" {
  description = "Number of application replicas"
  type        = number
  default     = 2
}

variable "app_host" {
  description = "Hostname for the Ingress resource"
  type        = string
  default     = "task-api.local"
}

variable "database_password" {
  description = "Password for PostgreSQL"
  type        = string
  sensitive   = true
}

variable "enable_hpa" {
  description = "Enable Horizontal Pod Autoscaler for task-api"
  type        = bool
  default     = true
}

variable "hpa_min_replicas" {
  description = "Minimum replicas for HPA"
  type        = number
  default     = 2
}

variable "hpa_max_replicas" {
  description = "Maximum replicas for HPA"
  type        = number
  default     = 10
}

variable "hpa_target_cpu" {
  description = "Target CPU utilization percentage for HPA"
  type        = number
  default     = 70
}
