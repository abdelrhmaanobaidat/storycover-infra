# Bucket for generated covers: private, uniform access, old objects expire to save credit.
resource "google_storage_bucket" "covers" {
  name                        = "${var.name}-covers"
  project                     = var.project_id
  location                    = var.region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  force_destroy               = true

  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type = "Delete"
    }
  }
}

# Least-privilege runtime identity for the app (bound to the K8s SA via Workload Identity).
resource "google_service_account" "app" {
  project      = var.project_id
  account_id   = "storycover-app"
  display_name = "StoryCover app runtime"
}

# Read/write only this bucket, nothing else in the project.
resource "google_storage_bucket_iam_member" "app_covers" {
  bucket = google_storage_bucket.covers.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.app.email}"
}

# Sign v4 URLs with no private key: the SA calls IAM SignBlob on itself.
resource "google_service_account_iam_member" "app_token_creator" {
  service_account_id = google_service_account.app.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:${google_service_account.app.email}"
}

# Workload Identity: let the K8s SA storycover/storycover-app act as this GCP SA.
resource "google_service_account_iam_member" "app_workload_identity" {
  service_account_id = google_service_account.app.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[storycover/storycover-app]"
}

output "covers_bucket" {
  value = google_storage_bucket.covers.name
}

output "app_service_account" {
  value = google_service_account.app.email
}
