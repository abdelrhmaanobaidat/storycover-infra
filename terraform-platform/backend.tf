# Separate in-cluster state (Helm needs a live cluster); bucket + prefix from envs/<env>.backend.hcl at init.
terraform {
  backend "gcs" {}
}
