terraform {
  backend "gcs" {
    bucket = "storycover-dev-tfstate"
    prefix = "terraform/dev"
  }
}
