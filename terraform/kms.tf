# Cloud KMS key for Vault auto-unseal, and the Vault server's GCP identity.
# Vault runs in-cluster (namespace/SA: vault/vault) and uses Workload Identity to call KMS
# for seal/unseal — no key files, no unseal keys to babysit.
#
# Note: KMS key rings and keys cannot be deleted (only key versions destroyed), so
# `terraform destroy` removes them from state but leaves them in the project. A re-apply
# reuses the same names. Acceptable for a disposable, short-lived environment.

resource "google_kms_key_ring" "vault" {
  name     = "${var.name}-vault"
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "vault_unseal" {
  name     = "vault-unseal"
  key_ring = google_kms_key_ring.vault.id
  purpose  = "ENCRYPT_DECRYPT"
}

resource "google_service_account" "vault" {
  project      = var.project_id
  account_id   = "${var.name}-vault"
  display_name = "Vault server (KMS auto-unseal)"
}

# Vault's GCP SA may encrypt/decrypt with the unseal key.
resource "google_kms_crypto_key_iam_member" "vault_unseal" {
  crypto_key_id = google_kms_crypto_key.vault_unseal.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.vault.email}"
}

# Workload Identity: the in-cluster KSA vault/vault acts as the Vault GCP SA.
resource "google_service_account_iam_member" "vault_wi" {
  service_account_id = google_service_account.vault.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[vault/vault]"
}
