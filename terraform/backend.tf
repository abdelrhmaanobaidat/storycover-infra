# Partial backend: bucket + prefix come from envs/<env>.backend.hcl at init time, so one
# root config serves both environments with isolated state per project.
terraform {
  backend "gcs" {}
}
