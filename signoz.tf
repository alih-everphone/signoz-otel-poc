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
  # Storage & ClickHouse config
  ###############################################

  set {
    name  = "global.storageClass"
    value = var.signoz_storage_class
  }

  set {
    name  = "clickhouse.installCustomStorageClass"
    value = "true"
  }

 ###############################################
  # Increase Resource Allocation for OpenTelemetry Collector
  ###############################################


  set {
    name  = "otelCollector.resources.requests.cpu"
    value = "4"
  }

  set {
    name  = "otelCollector.resources.requests.memory"
    value = "8Gi"
  }

  set {
    name  = "otelCollector.resources.limits.cpu"
    value = "4"
  }

  set {
    name  = "otelCollector.resources.limits.memory"
    value = "8Gi"
  }

  set {
    name  = "clickhouse.resources.requests.cpu"
    value = "4"
}

  set {
      name  = "clickhouse.resources.requests.memory"
      value = "8Gi"
  }

  set {
      name  = "clickhouse.resources.limits.cpu"
      value = "4"
  }

  set {
      name  = "clickhouse.resources.limits.memory"
      value = "8Gi"
  }

  set {
    name  = "signoz.resources.requests.cpu"
    value = "2"
  }

  set {
    name  = "signoz.resources.requests.memory"
    value = "4Gi"
  }

  set {
    name  = "signoz.resources.limits.cpu"
    value = "2"
  }

  set {
    name  = "signoz.resources.limits.memory"
    value = "4Gi"
  }
  set {
    name  = "zookeeper.resources.requests.cpu"
    value = "2"
  }

  set {
    name  = "zookeeper.resources.requests.memory"
    value = "4Gi"
  }

  set {
    name  = "zookeeper.resources.limits.cpu"
    value = "2"
  }

  set {
    name  = "zookeeper.resources.limits.memory"
    value = "4Gi"
  }

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
      host = "signoz.everphone.dev"
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

resource "kubernetes_manifest" "otel_backendconfig" {
  manifest = {
    "apiVersion" = "cloud.google.com/v1"
    "kind"       = "BackendConfig"
    "metadata" = {
      "name"      = "otel-backendconfig"
      "namespace" = var.signoz_namespace
    }
    "spec" = {
      "healthCheck" = {
          "type"               = "HTTP"
          "requestPath"        = "/"
          "port"               = 13133
          "checkIntervalSec"   = 10
          "timeoutSec"         = 5
          "healthyThreshold"   = 1
          "unhealthyThreshold" = 3
        }
  }
}
}


resource "kubernetes_ingress_v1" "signoz_otel_ingress" {
  metadata {
    name      = "signoz-otel-ingress"
    namespace = var.signoz_namespace

    annotations = {
      "kubernetes.io/ingress.class"       = "gce"
      "ingress.gcp.kubernetes.io/pre-shared-cert" = "everphone-dev-cert"
      "kubernetes.io/ingress.allow-http" = "true"
      "cloud.google.com/backend-config"   = jsonencode({
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
            path      = "/"
            path_type = "Prefix"
            backend {
              service {
                name = "signoz-otel-collector"
                port { number = 4318 }
              }
            }
          }
      }
    }
  }

  depends_on = [helm_release.signoz, kubernetes_manifest.otel_backendconfig]
}


data "kubernetes_ingress_v1" "signoz_otel_ingress" {
  metadata {
    name      = kubernetes_ingress_v1.signoz_otel_ingress.metadata[0].name
    namespace = kubernetes_ingress_v1.signoz_otel_ingress.metadata[0].namespace
  }
}
