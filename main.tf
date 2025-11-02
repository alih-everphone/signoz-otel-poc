resource "google_container_cluster" "signoz_cluster" {
  name               = var.cluster_name
  location           = var.gcp_region
  enable_autopilot   = true
  deletion_protection = false

  network    = "default"
  subnetwork = "default"

  release_channel {
    channel = "REGULAR"
  }
}
