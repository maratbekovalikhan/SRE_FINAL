# ─── EKS Cluster (stub — uncomment when deploying to AWS) ──────────────────

# module "eks" {
#   source = "../../modules/aws-eks"
#
#   cluster_name    = var.cluster_name
#   region          = var.aws_region
#   cluster_version = "1.30"
# }

# ─── Application ───────────────────────────────────────────────────────────

module "app" {
  source = "../../modules/kubernetes-app"

  app_image         = var.app_image
  database_password = var.database_password
  app_host          = "task-api.example.com"

  # In AWS, use the ALB Ingress Controller instead of nginx
  # Adjust ingress annotations accordingly
}

# ─── Monitoring ────────────────────────────────────────────────────────────

module "monitoring" {
  source = "../../modules/monitoring"

  app_namespace          = module.app.namespace_name
  grafana_admin_password = var.grafana_admin_password
  grafana_host           = "grafana.example.com"

  depends_on = [module.app]
}
