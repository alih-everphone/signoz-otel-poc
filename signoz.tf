###############################################
# SigNoz Helm Installation
###############################################

resource "helm_release" "signoz" {
  name             = "signoz"
  repository       = "https://charts.signoz.io"
  chart            = "signoz"
  version          = var.signoz_chart_version
  namespace        = var.signoz_namespace
  create_namespace = true
  depends_on       = [google_container_cluster.signoz_cluster]
  timeout          = 3600

  ###############################################
  # Use values.yaml instead of individual `set` blocks
  ###############################################

  values = [
    file("${path.module}/values.yaml")
  ]
}


###############################################
# Get OTEL Collector Service info
###############################################

data "kubernetes_service" "otel_collector" {
  depends_on = [helm_release.signoz]

  metadata {
    name      = "signoz-otel-collector"
    namespace = var.signoz_namespace
  }
}



###############################################
# Get SigNoz Main Service info
###############################################

data "kubernetes_service" "signoz_main" {
  depends_on = [helm_release.signoz]

  metadata {
    name      = "signoz"
    namespace = var.signoz_namespace
  }
}

  # ###############################################
  # # Kubernetes Ingress Configuration
  # ###############################################
resource "kubernetes_ingress_v1" "signoz_frontend_ingress" {
  metadata {
    name      = "signoz-frontend-ingress"
    namespace = "signoz"

    annotations = {
      "kubernetes.io/ingress.class"                     = "gce"
      "ingress.gcp.kubernetes.io/pre-shared-cert"      = "everphone-dev-cert"
      "kubernetes.io/ingress.allow-http"               = "false"
    }
  }

  spec {
    ingress_class_name = "gce"

    rule {
      host = "signoz.everphone.dev" #for ip based access use this
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "signoz"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}


###############################################
# BackendConfig: health check on port 13133
###############################################
resource "kubernetes_manifest" "otel_backendconfig" {

  manifest = {
    apiVersion = "cloud.google.com/v1"
    kind       = "BackendConfig"
    metadata = {
      name      = "otel-backendconfig"
      namespace = var.signoz_namespace
    }
    spec = {
      healthCheck = {
        type               = "HTTP"
        port               = 13133
        requestPath        = "/"
        checkIntervalSec   = 10
        timeoutSec         = 5
        healthyThreshold   = 1
        unhealthyThreshold = 3
      }
    }
  }
}


###############################################
# Ingress: traffic on 4318, health via BackendConfig
###############################################


resource "kubernetes_annotations" "otel_backendconfig_link" {
  api_version = "v1"
  kind        = "Service"

  metadata {
    name      = data.kubernetes_service.otel_collector.metadata[0].name
    namespace = var.signoz_namespace
  }
  force = true
  annotations = {
    "cloud.google.com/backend-config" = jsonencode({
      ports = {
        "otlp-http" = kubernetes_manifest.otel_backendconfig.manifest["metadata"]["name"]
        "otlp" = kubernetes_manifest.otel_backendconfig.manifest["metadata"]["name"]
      }
    })
  }
}


resource "kubernetes_ingress_v1" "signoz_otel_ingress" {
  metadata {
    name      = "signoz-otel-ingress"
    namespace = var.signoz_namespace

    annotations = {
      "kubernetes.io/ingress.class"               = "gce"
      "ingress.gcp.kubernetes.io/pre-shared-cert" = "everphone-dev-cert"
      "kubernetes.io/ingress.allow-http"          = "false"
      "cloud.google.com/backend-config" = jsonencode({
        "default" = kubernetes_manifest.otel_backendconfig.manifest["metadata"]["name"]
      })
    }
  }

  spec {
    ingress_class_name = "gce"

    rule {
      host = "signoz-ingest.everphone.dev"
      http {
        path {
          path      = "/v1"
          path_type = "Prefix"
          backend {
              service {
                name = data.kubernetes_service.otel_collector.metadata[0].name
                port {
                  name = "otlp-http" # 4318
                }
              }
            }
        }
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
              service {
                name = data.kubernetes_service.otel_collector.metadata[0].name
                port {
                  name = "otlp" # 4317
                }
              }
            }
        }
      }
    }
  }

  depends_on = [
    helm_release.signoz,
    kubernetes_manifest.otel_backendconfig
  ]
}


data "kubernetes_ingress_v1" "signoz_otel_ingress" {
  metadata {
    name      = kubernetes_ingress_v1.signoz_otel_ingress.metadata[0].name
    namespace = kubernetes_ingress_v1.signoz_otel_ingress.metadata[0].namespace
  }
}
