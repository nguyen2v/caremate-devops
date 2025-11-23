resource "google_service_account" "this" {
  account_id   = "caremate-service-acount"
  display_name = "Caremate Service Account"
}

resource "google_project_iam_member" "compute_role" {
  project = local.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.this.email}"
}

data "google_project" "current" {
  project_id = local.project_id
}

resource "google_project_iam_member" "compute_system_account_permissions" {
  project = local.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:service-${data.google_project.current.number}@compute-system.iam.gserviceaccount.com"
}
