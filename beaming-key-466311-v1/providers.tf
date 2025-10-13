terraform {
  backend "gcs" {
    bucket = "beaming-key-466311-v1-state"
    prefix = "terraform-state"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.38.0"
    }
  }

  required_version = "~> 1.0"
}

provider "google" {
  billing_project       = local.project_id
  project               = local.project_id
  user_project_override = true
}
