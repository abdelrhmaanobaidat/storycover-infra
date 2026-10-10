variable "project_id" {
  type        = string
  description = "Project that owns the cluster."
}

variable "location" {
  type        = string
  description = "A zone for a zonal cluster (dev) or a region for a regional cluster (prod)."
}

variable "cluster_name" {
  type = string
}

variable "network" {
  type        = string
  description = "VPC network name."
}

variable "subnetwork" {
  type        = string
  description = "Subnet name hosting the nodes."
}

variable "pods_range_name" {
  type        = string
  description = "Secondary range name for pods."
}

variable "services_range_name" {
  type        = string
  description = "Secondary range name for services."
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
