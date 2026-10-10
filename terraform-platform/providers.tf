provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_client_config" "default" {}

data "google_project" "this" {
  project_id = var.project_id
}

locals {
  # Connect Gateway endpoint (membership id = cluster name) — reaches the private API with a short-lived token.
  gateway_host = "https://${var.region}-connectgateway.googleapis.com/v1/projects/${data.google_project.this.number}/locations/${var.region}/gkeMemberships/${var.name}"
}

provider "helm" {
  kubernetes {
    host  = local.gateway_host
    token = data.google_client_config.default.access_token
  }
}
