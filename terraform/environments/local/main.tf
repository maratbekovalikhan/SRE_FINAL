module "app" {
  source = "../../modules/kubernetes-app"

  app_image         = var.app_image
  database_password = var.database_password
}

module "monitoring" {
  source = "../../modules/monitoring"

  app_namespace          = module.app.namespace_name
  grafana_admin_password = var.grafana_admin_password

  depends_on = [module.app]
}
