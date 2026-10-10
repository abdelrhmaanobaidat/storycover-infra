variable "project_id" {
  type        = string
  description = "GCP project for this environment."
}

variable "region" {
  type        = string
  description = "GCP region (also the cluster location)."
}

variable "name" {
  type        = string
  description = "Cluster / fleet-membership name, e.g. storycover-dev."
}

variable "argocd_chart_version" {
  type        = string
  default     = "10.10.2"
  description = "argo-cd Helm chart version (pinned for reproducible bootstraps)."
}

variable "gitops_repo_url" {
  type        = string
  default     = "https://github.com/abdelrhmaanobaidat/storycover-infra.git"
  description = "Repo the app-of-apps root watches (public; no Argo repo creds needed)."
}

variable "gitops_revision" {
  type        = string
  default     = "main"
  description = "Git revision the root app tracks (main for dev, prod for prod)."
}
