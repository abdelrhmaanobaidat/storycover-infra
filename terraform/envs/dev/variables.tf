variable "project_id" {
  type        = string
  description = "GCP project for the dev environment."
}

variable "region" {
  type        = string
  description = "GCP region (also the location of the regional Autopilot cluster)."
}
