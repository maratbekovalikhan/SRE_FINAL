# ─── Monitoring Namespace ───────────────────────────────────────────────────
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"

    labels = {
      "app.kubernetes.io/part-of" = "monitoring"
    }
  }
}

# ─── kube-prometheus-stack (Prometheus + Grafana + Alertmanager) ────────────
resource "helm_release" "kube_prometheus_stack" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version

  # Wait for all resources to be ready
  wait    = true
  timeout = 600

  values = [yamlencode({
    grafana = {
      adminPassword = var.grafana_admin_password

      service = {
        type = "ClusterIP"
      }

      ingress = {
        enabled          = true
        ingressClassName = "nginx"
        hosts            = [var.grafana_host]
      }
    }

    prometheus = {
      prometheusSpec = {
        # Allow Prometheus to discover ServiceMonitors/PodMonitors/Rules from ALL namespaces
        serviceMonitorSelectorNilUsesHelmValues = false
        podMonitorSelectorNilUsesHelmValues     = false
        ruleSelectorNilUsesHelmValues           = false
      }
    }
  })]
}

# ─── ServiceMonitor for task-api ───────────────────────────────────────────
resource "kubernetes_manifest" "app_service_monitor" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"

    metadata = {
      name      = "task-api-monitor"
      namespace = kubernetes_namespace.monitoring.metadata[0].name

      labels = {
        "app.kubernetes.io/part-of" = "task-api"
      }
    }

    spec = {
      selector = {
        matchLabels = {
          app = "task-api"
        }
      }

      namespaceSelector = {
        matchNames = [var.app_namespace]
      }

      endpoints = [
        {
          port     = "http"
          path     = "/metrics"
          interval = "15s"
        }
      ]
    }
  }

  depends_on = [helm_release.kube_prometheus_stack]
}
