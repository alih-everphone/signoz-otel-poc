###############################################
# SigNoz Helm Installation
###############################################

resource "helm_release" "signoz" {
  name       = "signoz"
  repository = "https://charts.signoz.io"
  chart      = "signoz"
  version    = var.signoz_chart_version
  namespace        = var.signoz_namespace
  create_namespace = true
  depends_on = [google_container_cluster.signoz_cluster]
  timeout = 3600

  set {
    name  = "global.storageClass"
    value = var.signoz_storage_class
  }

  set {
    name  = "clickhouse.installCustomStorageClass"
    value = "true"
  }

  ###############################################
  # Expose OpenTelemetry Collector
  ###############################################

  # Service type = LoadBalancer
  set {
    name  = "otelCollector.service.type"
    value = "LoadBalancer"
  }

  # Expose OTLP ports
  set {
    name  = "otelCollector.service.ports.otlpHttp.port"
    value = "4318"
  }

  set {
    name  = "otelCollector.service.ports.otlpGrpc.port"
    value = "4317"
  }

  # Make the collector listen on all interfaces
  set {
    name  = "otelCollector.config.receivers.otlp.protocols.grpc.endpoint"
    value = "0.0.0.0:4317"
  }

  set {
    name  = "otelCollector.config.receivers.otlp.protocols.http.endpoint"
    value = "0.0.0.0:4318"
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
