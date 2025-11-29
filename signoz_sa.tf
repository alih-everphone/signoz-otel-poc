resource "google_service_account" "signoz_sa" {
  account_id   = "signoz-k8s-sa"
  display_name = "Signoz Service Account for GKE Autopilot"
}

resource "google_service_account_iam_member" "signoz_sa_binding" {
  service_account_id = google_service_account.signoz_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.gcp_project_id}.svc.id.goog[${var.signoz_namespace}/signoz-sa]"
}

resource "google_project_iam_member" "sa_container_admin" {
  project = var.gcp_project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.signoz_sa.email}"
}
