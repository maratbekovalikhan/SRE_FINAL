output "grafana_url" {
  description = "URL to access Grafana (via Ingress)"
  value       = "http://${var.grafana_host}"
}

output "prometheus_namespace" {
  description = "Namespace where Prometheus stack is deployed"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}
