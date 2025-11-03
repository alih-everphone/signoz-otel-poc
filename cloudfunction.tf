# # Service account for Cloud Run
# resource "google_service_account" "cloud_run_sa" {
#   account_id   = "cloud-run-sa"
#   display_name = "Cloud Run Service Account"
# }

# # Cloud Run service
# resource "google_cloud_run_service" "hello_world_svc" {
#   name     = "hello-world-service"
#   location = var.gcp_region

#   template {
#     spec {
#       service_account_name = google_service_account.cloud_run_sa.email

#       containers {
#         image = "gcr.io/${var.gcp_project_id}/hello-world"
#         ports {
#           container_port = 8080
#         }
#       }

#       container_concurrency = 80
#     }
#   }

#   traffic {
#     latest_revision = true
#     percent         = 100
#   }
# }

# # Make it publicly invokable
# resource "google_cloud_run_service_iam_member" "all_users" {
#   location = google_cloud_run_service.hello_world_svc.location
#   project  = var.gcp_project_id
#   service  = google_cloud_run_service.hello_world_svc.name
#   role     = "roles/run.invoker"
#   member   = "allUsers"
# }

# # Cloud Build trigger connected to GitHub
# resource "google_cloudbuild_trigger" "github_trigger" {
#   name = "cloud-run-auto-deploy"

#   github {
#     owner = split("/", var.github_repo)[0]
#     name  = split("/", var.github_repo)[1]
#     push {
#       branch = "main"
#     }
#   }

#   filename = "cloudbuild.yaml" # must exist in your repo

#   substitutions = {
#     _REGION = var.gcp_region
#     _SERVICE = google_cloud_run_service.hello_world_svc.name
#     _PROJECT_ID = var.gcp_project_id
#   }
# }
