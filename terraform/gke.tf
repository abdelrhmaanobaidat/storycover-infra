locals {
  # IAM (via the node SA), not scopes, governs what nodes can do.
  node_oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
}

# Dedicated least-privilege node identity instead of the default Compute Engine SA.
resource "google_service_account" "nodes" {
  project      = var.project_id
  account_id   = "${var.name}-nodes"
  display_name = "GKE nodes for ${var.name}"
}

resource "google_project_iam_member" "nodes" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/stackdriver.resourceMetadata.writer",
    "roles/artifactregistry.reader",
  ])
  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.nodes.email}"
}

# Standard cluster: we manage the node pools (management vs application) explicitly.
resource "google_container_cluster" "this" {
  name     = var.name
  project  = var.project_id
  location = var.region

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  remove_default_node_pool = true
  initial_node_count       = 1

  release_channel {
    channel = var.release_channel
  }

  enable_shielded_nodes = true

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master_ipv4_cidr
  }

  # Private endpoint requires authorized networks enabled; no external CIDRs (operators
  # use Connect Gateway, nodes reach it internally).
  master_authorized_networks_config {}

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Connect Gateway (IAM-based, IP-independent) for the private control plane.
  fleet {
    project = var.project_id
  }

  deletion_protection = false
}

# Management pool: on-demand, UNTAINTED so kube-system + platform tools (Argo CD, Vault,
# monitoring) schedule here. Labelled for nodeSelector pinning.
resource "google_container_node_pool" "management" {
  name     = "management"
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.this.name

  autoscaling {
    total_min_node_count = var.mgmt_min_nodes
    total_max_node_count = var.mgmt_max_nodes
    location_policy      = "BALANCED"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.mgmt_machine_type
    service_account = google_service_account.nodes.email
    oauth_scopes    = local.node_oauth_scopes

    labels = {
      workload = "management"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}

# Application pool: Spot + autoscaling, TAINTED so only app workloads (with a matching
# toleration) land here. This is the management/application segregation (Objective 1).
resource "google_container_node_pool" "application" {
  name     = "application"
  project  = var.project_id
  location = var.region
  cluster  = google_container_cluster.this.name

  autoscaling {
    total_min_node_count = var.app_min_nodes
    total_max_node_count = var.app_max_nodes
    location_policy      = "ANY"
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.app_machine_type
    service_account = google_service_account.nodes.email
    oauth_scopes    = local.node_oauth_scopes
    spot            = var.app_spot

    labels = {
      workload = "application"
    }

    taint {
      key    = "workload"
      value  = "application"
      effect = "NO_SCHEDULE"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}
