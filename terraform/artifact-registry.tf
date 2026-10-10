# Docker registry for the app image. app-ci pushes here; nodes pull via the node SA.
resource "google_artifact_registry_repository" "app" {
  project       = var.project_id
  location      = var.region
  repository_id = "storycover"
  format        = "DOCKER"
  description   = "StoryCover application images"

  # Keep storage small: drop untagged images after a week, keep the last 10 tagged.
  cleanup_policy_dry_run = false

  cleanup_policies {
    id     = "untagged"
    action = "DELETE"
    condition {
      tag_state  = "UNTAGGED"
      older_than = "604800s"
    }
  }

  cleanup_policies {
    id     = "keep-recent"
    action = "KEEP"
    most_recent_versions {
      keep_count = 10
    }
  }
}

output "artifact_registry_repo" {
  value = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.app.repository_id}"
}
