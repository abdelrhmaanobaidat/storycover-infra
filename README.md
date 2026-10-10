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
      modules/        reusable modules (network, gke, gcs, edge, iam, kms)
      envs/dev        dev environment (zonal cluster, me-central1-a)
      envs/prod       prod environment (regional cluster)

## State

Remote state in GCS, one bucket per environment:

- dev:  `gs://storycover-dev-tfstate`  (prefix `terraform/dev`)
- prod: `gs://storycover-prod-tfstate` (prefix `terraform/prod`)

## Usage

    cd terraform/envs/dev
    terraform init
    terraform plan
    terraform apply

Region: `me-central1` (Doha). Project per environment: `storycover-dev`, `storycover-prod`.
