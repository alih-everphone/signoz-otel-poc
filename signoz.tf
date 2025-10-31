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
}
