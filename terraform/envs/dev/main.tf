module "network" {
  source = "../../modules/network"

  project_id    = var.project_id
  region        = var.region
  network_name  = "storycover-dev"
  subnet_cidr   = "10.10.0.0/20"
  pods_cidr     = "10.20.0.0/16"
  services_cidr = "10.30.0.0/20"
}

module "gke" {
  source = "../../modules/gke"

  project_id   = var.project_id
  location     = var.zone
  cluster_name = "storycover-dev"

  network             = module.network.network_name
  subnetwork          = module.network.subnet_name
  pods_range_name     = module.network.pods_range_name
  services_range_name = module.network.services_range_name
}
