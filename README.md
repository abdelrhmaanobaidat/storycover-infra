# storycover-infra

Terraform and platform configuration for the StoryCover GKE environments.

## Prerequisite (one-time bootstrap)

Before the pipeline can run, each project needs a bootstrap layer that the pipeline
cannot create for itself (it authenticates *with* these): a GCS state bucket, a Workload
Identity provider, and the `infra-ci` service account. These are provisioned once, by
hand, with `gcloud`; the bootstrap script is kept out of this repo. Everything else is
managed by Terraform through the pipeline.

## Layout

    terraform/
      vpc.tf gke.tf ... outputs.tf    one flat root, one file per concern
      variables.tf providers.tf versions.tf backend.tf (partial) moved.tf
      envs/
        dev.tfvars   dev.backend.hcl   per-env values + state location
        prod.tfvars  prod.backend.hcl

One root config serves both environments; `envs/<env>.tfvars` supplies the values and
`envs/<env>.backend.hcl` selects the per-project state bucket at `init` time.

## State

Remote state in GCS, one bucket per environment:

- dev:  `gs://storycover-dev-tfstate`  (prefix `terraform/dev`)
- prod: `gs://storycover-prod-tfstate` (prefix `terraform/prod`)

## Usage

    cd terraform
    terraform init  -backend-config=envs/dev.backend.hcl
    terraform plan  -var-file=envs/dev.tfvars
    # applies run in CI (merge), gated by Environment approval

Region: `me-central1` (Doha). Project per environment: `storycover-dev`, `storycover-prod`.
