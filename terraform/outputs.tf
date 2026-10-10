output "network_name" {
  value = google_compute_network.vpc.name
}

output "subnet_name" {
  value = google_compute_subnetwork.subnet.name
}

output "cluster_name" {
  value = google_container_cluster.this.name
}

output "node_service_account" {
  value = google_service_account.nodes.email
}
