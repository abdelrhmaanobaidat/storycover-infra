# Global external IP for the HTTPS load balancer; the hostname is derived from it via sslip.io.
resource "google_compute_global_address" "edge" {
  name    = "storycover-edge"
  project = var.project_id
}

locals {
  edge_hostname = "${google_compute_global_address.edge.address}.sslip.io"
}

# Google-managed TLS cert for the sslip.io host. No dns_authorizations => load-balancer
# authorization, which works because sslip.io resolves the host straight to the LB IP.
resource "google_certificate_manager_certificate" "edge" {
  name    = "storycover-edge"
  project = var.project_id
  managed {
    domains = [local.edge_hostname]
  }
}

resource "google_certificate_manager_certificate_map" "edge" {
  name    = "storycover-edge"
  project = var.project_id
}

resource "google_certificate_manager_certificate_map_entry" "edge" {
  name         = "storycover-edge"
  project      = var.project_id
  map          = google_certificate_manager_certificate_map.edge.name
  certificates = [google_certificate_manager_certificate.edge.id]
  hostname     = local.edge_hostname
}

# Cloud Armor: per-IP rate limit in front of the app (the "Cloudflare equivalent").
resource "google_compute_security_policy" "edge" {
  name    = "storycover-edge"
  project = var.project_id

  rule {
    action      = "throttle"
    priority    = 1000
    description = "Rate limit each client IP"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    rate_limit_options {
      conform_action = "allow"
      exceed_action  = "deny(429)"
      enforce_on_key = "IP"
      rate_limit_threshold {
        count        = 100
        interval_sec = 60
      }
    }
  }

  rule {
    action      = "allow"
    priority    = 2147483647
    description = "Default allow"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
  }
}

output "edge_ip" {
  value = google_compute_global_address.edge.address
}

output "edge_hostname" {
  value = local.edge_hostname
}

output "edge_cert_map" {
  value = google_certificate_manager_certificate_map.edge.name
}

output "edge_security_policy" {
  value = google_compute_security_policy.edge.name
}
