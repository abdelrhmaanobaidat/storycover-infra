# Separate state from the infra root (which creates the cluster). This layer manages
# in-cluster resources via the Helm provider, which needs a live cluster — so it is a
# distinct root/state applied after the infra root. bucket + prefix come from
# envs/<env>.backend.hcl at init time.
terraform {
  backend "gcs" {}
}
