terraform {
  backend "gcs" {
    bucket = "storycover-prod-tfstate"
    prefix = "terraform/prod"
  }
}
