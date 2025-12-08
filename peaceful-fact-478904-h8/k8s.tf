module "k8s" {
  source = "../modules/caremate-gcp-k8s"

  project_id = local.project_id

  storage_domain = "storage.domain"
  app_domain     = "app.domain"

  master_authorized_networks = []

  region = local.region_southeast1
  zone   = local.zone_southeast1
}
