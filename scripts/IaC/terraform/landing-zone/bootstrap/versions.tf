#https://registry.terraform.io/providers/hashicorp/google/latest/docs
terraform {
  backend "gcs" {
    bucket = "organization-gcs-all-iac"
    prefix = "landing-zone/bootstrap"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.40.0"
    }
  }
}

provider "google" {}
