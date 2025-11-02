terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = { source = "hashicorp/google", version = "~> 6.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 2.32" }
    helm = { source = "hashicorp/helm", version = "~> 2.12" }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}

data "google_client_config" "default" {}

data "google_container_cluster" "signoz_cluster" {
  name     = google_container_cluster.signoz_cluster.name
  location = google_container_cluster.signoz_cluster.location
  depends_on = [google_container_cluster.signoz_cluster]
}

# Kubernetes provider for GKE
provider "kubernetes" {
  host                   = "https://${data.google_container_cluster.signoz_cluster.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.signoz_cluster.master_auth[0].cluster_ca_certificate
  )
}


# Helm provider pointing to the same Kubernetes cluster
provider "helm" {
  kubernetes {
    host                   = "https://${data.google_container_cluster.signoz_cluster.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.signoz_cluster.master_auth[0].cluster_ca_certificate
    )
  }
}
