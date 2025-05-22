# ---------------------------
# Secret pour PostgreSQL
# ---------------------------
resource "kubernetes_secret" "postgres_secret" {
  metadata {
    name = "postgres-credentials"
  }

  data = {
    POSTGRES_USER     = var.postgres_user
    POSTGRES_PASSWORD = var.postgres_password
    POSTGRES_DB       = var.postgres_db
  }

  type = "Opaque"
}

# ---------------------------
# Persistent Volume Claim
# ---------------------------
resource "kubernetes_persistent_volume_claim" "postgres_pvc" {
  metadata {
    name = "postgres-pvc"
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

# ---------------------------
# Déploiement PostgreSQL
# ---------------------------
resource "kubernetes_deployment" "postgres" {
  metadata {
    name = "postgres"
  }

  wait_for_rollout        = true
 

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
          image = "postgres:latest"

          env_from {
            secret_ref {
              name = kubernetes_secret.postgres_secret.metadata[0].name
            }
          }

          port {
            container_port = 5432
          }

          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }

          resources {
            limits = {
              memory = "512Mi"
              cpu    = "1000m"
            }

            requests = {
              memory = "256Mi"
              cpu    = "250m"
            }
          }

          readiness_probe {
            exec {
              command = ["pg_isready", "-U", var.postgres_user]
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }

          liveness_probe {
            exec {
              command = ["pg_isready", "-U", var.postgres_user]
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }
        }

        volume {
          name = "postgres-data"

          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres_pvc.metadata[0].name
          }
        }
      }
    }
  }
}

# ---------------------------
# Service PostgreSQL
# ---------------------------
resource "kubernetes_service" "postgres_service" {
  metadata {
    name = "database"
  }

  spec {
    selector = {
      app = "postgres"
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}

# ---------------------------
# Déploiement Backend
# ---------------------------
resource "kubernetes_deployment" "backend" {
  metadata {
    name = "backend"
  }

  wait_for_rollout        = true
  

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "backend"
      }
    }

    template {
      metadata {
        labels = {
          app = "backend"
        }
      }

      spec {
        container {
          name  = "backend"
          image = "nayoh/odc_monback"

          env_from {
            secret_ref {
              name = kubernetes_secret.postgres_secret.metadata[0].name
            }
          }

          port {
            container_port = 8000
          }

          image_pull_policy = "Always"

          resources {
            limits = {
              memory = "256Mi"
              cpu    = "500m"
            }

            requests = {
              memory = "128Mi"
              cpu    = "150m"
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 8000
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 8000
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
      }
    }
  }
}

# ---------------------------
# Service Backend
# ---------------------------
resource "kubernetes_service" "backend_service" {
  metadata {
    name = "backend"
  }

  spec {
    selector = {
      app = "backend"
    }

    type = "NodePort"

    port {
      port        = 8000
      target_port = 8000
      node_port   = 30519
    }
  }
}

# ---------------------------
# Déploiement Frontend
# ---------------------------
resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "front-app"
  }

  wait_for_rollout        = true
  

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "front-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "front-app"
        }
      }

      spec {
        container {
          name  = "frontend-container"
          image = "nayoh/odc_monfront4"

          port {
            container_port = 80
          }

          image_pull_policy = "Always"

          resources {
            limits = {
              memory = "256Mi"
              cpu    = "500m"
            }

            requests = {
              memory = "128Mi"
              cpu    = "150m"
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 5
            period_seconds        = 5
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80
            }
            initial_delay_seconds = 10
            period_seconds        = 10
          }
        }
      }
    }
  }
}

# ---------------------------
# Service Frontend
# ---------------------------
resource "kubernetes_service" "frontend_service" {
  metadata {
    name = "front-service"
  }

  spec {
    selector = {
      app = "front-app"
    }

    type = "NodePort"

    port {
      port        = 80
      target_port = 80
      node_port   = 30517
    }
  }
}
