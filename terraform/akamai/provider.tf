terraform {
  backend "pg" {
    conn_str    = "postgres://postgres@localhost/caremate_terraform?sslmode=disable"
    schema_name = "public"
  }

  required_providers {
    linode = {
      source  = "linode/linode"
      version = "3.7.0"
    }
  }
}

provider "linode" {}
