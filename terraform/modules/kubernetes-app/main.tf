# ─── Namespace ──────────────────────────────────────────────────────────────
resource "kubernetes_namespace" "app" {
  metadata {
    name = var.namespace

    labels = {
      "app.kubernetes.io/part-of" = "task-api"
    }
  }
}

# ─── ConfigMap ──────────────────────────────────────────────────────────────
resource "kubernetes_config_map" "app" {
  metadata {
    name      = "app-config"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      "app.kubernetes.io/part-of" = "task-api"
    }
  }

  data = {
    # Placeholder URL — real password is injected via Secret override
    DATABASE_URL       = "postgresql+asyncpg://taskuser:REPLACE_AT_RUNTIME@postgres-service:5432/taskdb"
    REDIS_URL          = "redis://redis-service:6379/0"
    SIMULATE_DELAY_MS  = "0"
    SIMULATE_ERROR_RATE = "0.0"
  }
}

# ─── Secret ─────────────────────────────────────────────────────────────────
resource "kubernetes_secret" "app" {
  metadata {
    name      = "app-secrets"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      "app.kubernetes.io/part-of" = "task-api"
    }
  }

  data = {
    DATABASE_PASSWORD = var.database_password
    # Full URL with real password — overrides ConfigMap value at pod level
    DATABASE_URL = "postgresql+asyncpg://taskuser:${var.database_password}@postgres-service:5432/taskdb"
  }

  type = "Opaque"
}

# ─── PostgreSQL PVC ─────────────────────────────────────────────────────────
resource "kubernetes_persistent_volume_claim" "postgres" {
  metadata {
    name      = "postgres-pvc"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      "app.kubernetes.io/part-of" = "task-api"
    }
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    resources {
      requests = {
        storage = "1Gi"
      }
    }
  }
}

# ─── PostgreSQL Deployment ──────────────────────────────────────────────────
resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app                        = "postgres"
      "app.kubernetes.io/part-of" = "task-api"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "postgres"
      }
    }

    template {
      metadata {
        labels = {
          app = "postgres"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:16-alpine"

          port {
            container_port = 5432
          }

          env {
            name  = "POSTGRES_DB"
            value = "taskdb"
          }

          env {
            name  = "POSTGRES_USER"
            value = "taskuser"
          }

          env {
            name = "POSTGRES_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app.metadata[0].name
                key  = "DATABASE_PASSWORD"
              }
            }
          }

          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }

          volume_mount {
            name       = "postgres-storage"
            mount_path = "/var/lib/postgresql/data"
          }

          resources {
            requests = {
              memory = "256Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "512Mi"
              cpu    = "500m"
            }
          }

          readiness_probe {
            exec {
              command = ["pg_isready", "-U", "taskuser", "-d", "taskdb"]
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }

        volume {
          name = "postgres-storage"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres.metadata[0].name
          }
        }
      }
    }
  }
}

# ─── PostgreSQL Service ─────────────────────────────────────────────────────
resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres-service"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app                        = "postgres"
      "app.kubernetes.io/part-of" = "task-api"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}

# ─── Redis Deployment ───────────────────────────────────────────────────────
resource "kubernetes_deployment" "redis" {
  metadata {
    name      = "redis"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app                        = "redis"
      "app.kubernetes.io/part-of" = "task-api"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "redis"
      }
    }

    template {
      metadata {
        labels = {
          app = "redis"
        }
      }

      spec {
        container {
          name  = "redis"
          image = "redis:7-alpine"

          port {
            container_port = 6379
          }

          command = ["redis-server", "--maxmemory", "64mb", "--maxmemory-policy", "allkeys-lru"]

          resources {
            requests = {
              memory = "64Mi"
              cpu    = "50m"
            }
            limits = {
              memory = "128Mi"
              cpu    = "200m"
            }
          }

          readiness_probe {
            exec {
              command = ["redis-cli", "ping"]
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }
      }
    }
  }
}

# ─── Redis Service ──────────────────────────────────────────────────────────
resource "kubernetes_service" "redis" {
  metadata {
    name      = "redis-service"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app                        = "redis"
      "app.kubernetes.io/part-of" = "task-api"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "redis"
    }

    port {
      port        = 6379
      target_port = 6379
    }
  }
}

# ─── Task API Deployment ───────────────────────────────────────────────────
resource "kubernetes_deployment" "app" {
  metadata {
    name      = "task-api"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app                        = "task-api"
      "app.kubernetes.io/part-of" = "task-api"
    }
  }

  spec {
    replicas = var.app_replicas

    selector {
      match_labels = {
        app = "task-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "task-api"
        }

        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "8000"
          "prometheus.io/path"   = "/metrics"
        }
      }

      spec {
        container {
          name              = "task-api"
          image             = var.app_image
          image_pull_policy = "IfNotPresent"

          port {
            container_port = 8000
            name           = "http"
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.app.metadata[0].name
            }
          }

          # Secret overrides ConfigMap's DATABASE_URL with one containing real password
          env {
            name = "DATABASE_URL"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.app.metadata[0].name
                key  = "DATABASE_URL"
              }
            }
          }

          resources {
            requests = {
              memory = "128Mi"
              cpu    = "100m"
            }
            limits = {
              memory = "256Mi"
              cpu    = "500m"
            }
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = 8000
            }
            initial_delay_seconds = 10
            period_seconds        = 15
            timeout_seconds       = 3
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = 8000
            }
            initial_delay_seconds = 5
            period_seconds        = 10
            timeout_seconds       = 3
            failure_threshold     = 3
          }
        }
      }
    }
  }
}

# ─── Task API Service ──────────────────────────────────────────────────────
resource "kubernetes_service" "app" {
  metadata {
    name      = "task-api-service"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      app                        = "task-api"
      "app.kubernetes.io/part-of" = "task-api"
    }
  }

  spec {
    type = "ClusterIP"

    selector = {
      app = "task-api"
    }

    port {
      port        = 80
      target_port = 8000
    }
  }
}

# ─── Ingress ───────────────────────────────────────────────────────────────
resource "kubernetes_ingress_v1" "app" {
  metadata {
    name      = "task-api-ingress"
    namespace = kubernetes_namespace.app.metadata[0].name

    labels = {
      "app.kubernetes.io/part-of" = "task-api"
    }

    annotations = {
      "nginx.ingress.kubernetes.io/proxy-body-size" = "1m"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      host = var.app_host

      http {
        path {
          path      = "/"
          path_type = "Prefix"

          backend {
            service {
              name = kubernetes_service.app.metadata[0].name

              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# ─── Horizontal Pod Autoscaler ─────────────────────────────────────────────
resource "kubernetes_horizontal_pod_autoscaler_v2" "app" {
  count = var.enable_hpa ? 1 : 0

  metadata {
    name      = "task-api-hpa"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    min_replicas = var.hpa_min_replicas
    max_replicas = var.hpa_max_replicas

    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment.app.metadata[0].name
    }

    metric {
      type = "Resource"

      resource {
        name = "cpu"

        target {
          type                = "Utilization"
          average_utilization = var.hpa_target_cpu
        }
      }
    }
  }
}
