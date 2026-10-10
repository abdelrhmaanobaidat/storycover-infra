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

output "vault_gcp_service_account" {
  value = google_service_account.vault.email
}

output "vault_kms_key_ring" {
  value = google_kms_key_ring.vault.name
}

output "vault_kms_crypto_key" {
  value = google_kms_crypto_key.vault_unseal.name
}
