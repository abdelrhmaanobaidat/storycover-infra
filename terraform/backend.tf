# Partial backend: bucket + prefix come from envs/<env>.backend.hcl at init time.
terraform {
  backend "gcs" {}
}
