# storycover-infra

Terraform and platform configuration for the StoryCover GKE environments.

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
