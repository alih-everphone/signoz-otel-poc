# # Private VPC and subnets
# resource "google_compute_network" "signoz_vpc" {
#   name                    = var.vpc_name
#   auto_create_subnetworks = false
# }

# resource "google_compute_subnetwork" "signoz_subnet" {
#   name                     = var.subnet_name
#   ip_cidr_range            = var.subnet_cidr
#   region                   = var.gcp_region
#   network                  = google_compute_network.signoz_vpc.id
#   private_ip_google_access = true
# }

# resource "google_container_cluster" "signoz_cluster" {
#   name                = var.cluster_name
#   location            = var.gcp_region
#   enable_autopilot    = true
#   network             = google_compute_network.signoz_vpc.id
#   subnetwork          = google_compute_subnetwork.signoz_subnet.id
#   deletion_protection = false

#   release_channel {
#     channel = "REGULAR"
#   }
# }


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
