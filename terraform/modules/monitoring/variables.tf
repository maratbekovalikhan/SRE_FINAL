variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  sensitive   = true
  default     = "admin"
}

variable "grafana_host" {
  description = "Hostname for Grafana Ingress"
  type        = string
  default     = "grafana.local"
}

variable "app_namespace" {
  description = "Namespace where the application runs (for ServiceMonitor)"
  type        = string
}

variable "chart_version" {
  description = "Version of the kube-prometheus-stack Helm chart"
  type        = string
  default     = "65.0.0"
}
