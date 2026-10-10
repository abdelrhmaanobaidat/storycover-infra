# Re-map state from the previous module layout to the flat layout, so existing resources
# (e.g. the running dev cluster) move in place instead of being destroyed and recreated.
# Safe to keep; can be removed once all environments have applied once.
moved {
  from = module.network.google_compute_network.vpc
  to   = google_compute_network.vpc
}
moved {
  from = module.network.google_compute_subnetwork.subnet
  to   = google_compute_subnetwork.subnet
}
moved {
  from = module.network.google_compute_router.router
  to   = google_compute_router.router
}
moved {
  from = module.network.google_compute_router_nat.nat
  to   = google_compute_router_nat.nat
}
moved {
  from = module.network.google_compute_firewall.allow_internal
  to   = google_compute_firewall.allow_internal
}
moved {
  from = module.network.google_compute_firewall.allow_health_checks
  to   = google_compute_firewall.allow_health_checks
}
moved {
  from = module.network.google_compute_firewall.allow_iap_ssh
  to   = google_compute_firewall.allow_iap_ssh
}
moved {
  from = module.gke.google_container_cluster.this
  to   = google_container_cluster.this
}
