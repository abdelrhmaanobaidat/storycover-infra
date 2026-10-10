variable "project_id" {
  type        = string
  description = "Project that owns the cluster."
}

variable "location" {
  type        = string
  description = "Region for the Autopilot cluster (Autopilot clusters are regional)."
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
