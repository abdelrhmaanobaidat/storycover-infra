variable "project_id" {
  type        = string
  description = "GCP project for the dev environment."
}

variable "region" {
  type        = string
  description = "GCP region."
}

variable "zone" {
  type        = string
  description = "Zone for the dev (zonal) cluster."
}
