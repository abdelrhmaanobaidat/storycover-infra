locals {
  # IAM, not scopes, governs what nodes can do; the node SA holds minimal roles.
  oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
}

# Dedicated node identity instead of the default Compute Engine service account.
resource "google_service_account" "nodes" {
  project      = var.project_id
  account_id   = "${var.cluster_name}-nodes"
  display_name = "GKE nodes for ${var.cluster_name}"
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

resource "google_container_cluster" "this" {
  name     = var.cluster_name
  project  = var.project_id
  location = var.location

  network    = var.network
  subnetwork = var.subnetwork

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_secondary_range_name  = var.pods_range_name
    services_secondary_range_name = var.services_range_name
  }

  # Our own node pools are defined below.
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

  # Register to the project fleet so operators reach the API via Connect Gateway
  # (IAM-based, IP-independent). The control-plane endpoint stays fully private.
  fleet {
    project = var.project_id
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Disposable environments; allow terraform destroy.
  deletion_protection = false
}

resource "google_container_node_pool" "management" {
  name     = "management"
  project  = var.project_id
  location = var.location
  cluster  = google_container_cluster.this.name

  autoscaling {
    min_node_count = var.mgmt_min_nodes
    max_node_count = var.mgmt_max_nodes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.mgmt_machine_type
    service_account = google_service_account.nodes.email
    oauth_scopes    = local.oauth_scopes

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

resource "google_container_node_pool" "application" {
  name     = "application"
  project  = var.project_id
  location = var.location
  cluster  = google_container_cluster.this.name

  autoscaling {
    min_node_count = var.app_min_nodes
    max_node_count = var.app_max_nodes
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    machine_type    = var.app_machine_type
    service_account = google_service_account.nodes.email
    oauth_scopes    = local.oauth_scopes
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
