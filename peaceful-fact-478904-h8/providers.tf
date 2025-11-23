terraform {
  backend "gcs" {
    bucket = "peaceful-fact-478904-h8-state"
    prefix = "terraform-state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "7.12.0"
    }
  }

  required_version = "~> 1.14"
}

provider "google" {
  billing_project       = local.project_id
  project               = local.project_id
  user_project_override = true
}
