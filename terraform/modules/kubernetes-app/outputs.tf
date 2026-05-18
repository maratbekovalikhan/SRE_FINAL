output "namespace_name" {
  description = "Name of the created Kubernetes namespace"
  value       = kubernetes_namespace.app.metadata[0].name
}

output "app_service_name" {
  description = "Name of the task-api Service"
  value       = kubernetes_service.app.metadata[0].name
}

output "ingress_host" {
  description = "Hostname configured on the Ingress"
  value       = var.app_host
}
