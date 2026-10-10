# Autopilot cluster: Google manages the nodes (Shielded nodes, Workload Identity, secure
# defaults, auto-scaling/repair/upgrade are built in). Management vs application workloads
# are separated by namespace, not node pool.
resource "google_container_cluster" "this" {
  name     = var.name
  project  = var.project_id
  location = var.region

  enable_autopilot = true

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  release_channel {
    channel = var.release_channel
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr
  }

  # A private endpoint requires authorized networks to be enabled. No external CIDRs:
  # operators reach the API via Connect Gateway; nodes reach it internally.
  master_authorized_networks_config {}

  # Register to the project fleet so operators reach the API via Connect Gateway
  # (IAM-based, IP-independent). The control-plane endpoint stays fully private.
  fleet {
    project = var.project_id
  }

  # Disposable environments; allow terraform destroy.
  deletion_protection = false
}
