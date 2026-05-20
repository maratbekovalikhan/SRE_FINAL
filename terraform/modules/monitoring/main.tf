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
  timeout = 1800

  values = [yamlencode({
    kubeEtcd = {
      enabled = false
    }

    kubeControllerManager = {
      enabled = false
    }

    kubeScheduler = {
      enabled = false
    }

    kubeProxy = {
      enabled = false
    }

    coreDns = {
      enabled = false
    }

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

      resources = {
        requests = {
          cpu    = "50m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "200m"
          memory = "256Mi"
        }
      }
    }

    prometheus = {
      prometheusSpec = {
        # Allow Prometheus to discover ServiceMonitors/PodMonitors/Rules from ALL namespaces
        serviceMonitorSelectorNilUsesHelmValues = false
        podMonitorSelectorNilUsesHelmValues     = false
        ruleSelectorNilUsesHelmValues           = false
        retention                              = "24h"
        walCompression                         = true

        resources = {
          requests = {
            cpu    = "100m"
            memory = "512Mi"
          }
          limits = {
            cpu    = "500m"
            memory = "1Gi"
          }
        }
      }
    }

    prometheusOperator = {
      admissionWebhooks = {
        enabled = false
      }

      resources = {
        requests = {
          cpu    = "50m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "250m"
          memory = "256Mi"
        }
      }
    }

    alertmanager = {
      alertmanagerSpec = {
        resources = {
          requests = {
            cpu    = "50m"
            memory = "128Mi"
          }
          limits = {
            cpu    = "200m"
            memory = "256Mi"
          }
        }
      }
    }

    "kube-state-metrics" = {
      resources = {
        requests = {
          cpu    = "50m"
          memory = "128Mi"
        }
        limits = {
          cpu    = "200m"
          memory = "256Mi"
        }
      }
    }

    "prometheus-node-exporter" = {
      resources = {
        requests = {
          cpu    = "20m"
          memory = "32Mi"
        }
        limits = {
          cpu    = "100m"
          memory = "128Mi"
        }
      }
    }
  })]
}

# ─── Apply CRD-backed monitoring manifests after Helm installs the CRDs ─────
resource "null_resource" "monitoring_manifests" {
  triggers = {
    service_monitor_sha = filesha256("${path.module}/../../../monitoring/servicemonitor.yaml")
    prometheus_rule_sha = filesha256("${path.module}/../../../monitoring/prometheus-rule.yaml")
    app_namespace       = var.app_namespace
  }

  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/../../../monitoring/servicemonitor.yaml && kubectl apply -f ${path.module}/../../../monitoring/prometheus-rule.yaml"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "kubectl delete -f ${path.module}/../../../monitoring/prometheus-rule.yaml --ignore-not-found && kubectl delete -f ${path.module}/../../../monitoring/servicemonitor.yaml --ignore-not-found"
  }

  depends_on = [helm_release.kube_prometheus_stack]
}
