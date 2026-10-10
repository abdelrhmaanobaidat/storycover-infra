provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

data "google_project" "this" {
  project_id = var.project_id
}

locals {
  # Connect Gateway endpoint for the cluster's fleet membership (membership id = cluster
  # name). Lets the Helm provider reach the private control plane with a short-lived token,
  # IP-independent — the same path operators use via `gcloud ... get-credentials`.
  gateway_host = "https://${var.region}-connectgateway.googleapis.com/v1/projects/${data.google_project.this.number}/locations/${var.region}/gkeMemberships/${var.name}"
}

provider "helm" {
  kubernetes {
    host  = local.gateway_host
    token = data.google_client_config.default.access_token
  }
}
