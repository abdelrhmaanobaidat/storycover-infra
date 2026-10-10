variable "project_id" {
  type        = string
  description = "GCP project for this environment."
}

variable "region" {
  type        = string
  description = "GCP region (also the location of the regional Autopilot cluster)."
}

variable "name" {
  type        = string
  description = "Resource name prefix, e.g. storycover-dev."
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.0.0/20"
}

variable "pods_cidr" {
  type    = string
  default = "10.20.0.0/16"
}

variable "services_cidr" {
  type    = string
  default = "10.30.0.0/20"
}

variable "master_ipv4_cidr" {
  type        = string
  default     = "172.16.0.0/28"
  description = "Private range for the control plane. Must not overlap the subnet ranges."
}

variable "release_channel" {
  type    = string
  default = "REGULAR"
}

# Management node pool (on-demand). Totals are region-wide (not per-zone).
variable "mgmt_machine_type" {
  type    = string
  default = "e2-standard-2"
}

variable "mgmt_min_nodes" {
  type    = number
  default = 1
}

variable "mgmt_max_nodes" {
  type    = number
  default = 2
}

# Application node pool (Spot).
variable "app_machine_type" {
  type    = string
  default = "e2-small"
}

variable "app_spot" {
  type    = bool
  default = true
}

variable "app_min_nodes" {
  type    = number
  default = 1
}

variable "app_max_nodes" {
  type    = number
  default = 3
}
