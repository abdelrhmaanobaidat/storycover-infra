variable "project_id" {
  type        = string
  description = "Project that owns the network."
}

variable "region" {
  type        = string
  description = "Region for the subnet, router and NAT."
}

variable "network_name" {
  type        = string
  description = "Base name for the VPC and its resources."
}

variable "subnet_cidr" {
  type        = string
  description = "Primary range for nodes."
}

variable "pods_cidr" {
  type        = string
  description = "Secondary range for GKE pods (alias IPs)."
}

variable "services_cidr" {
  type        = string
  description = "Secondary range for GKE services (alias IPs)."
}
