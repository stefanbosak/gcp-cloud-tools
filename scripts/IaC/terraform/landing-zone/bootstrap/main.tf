locals {
  # Defines the roles for the default groups
  # https://cloud.google.com/iam/docs/roles-permissions/
  iam_groups = {
    "admin" = {
      group = "gcp-administrators"
      roles = [
        "roles/owner",
        "roles/resourcemanager.folderAdmin",
        "roles/resourcemanager.projectCreator",
        "roles/orgpolicy.policyAdmin",
        "roles/resourcemanager.organizationAdmin",
        "roles/compute.xpnAdmin",
        "roles/iap.tunnelResourceAccessor",
        "roles/compute.osLogin",
        "roles/artifactregistry.writer",
        "roles/iam.securityAdmin",
        "roles/iam.organizationRoleAdmin"
      ]
    },
    "devops" = {
      group = "gcp-devops"
      roles = [
        "roles/viewer",
        "roles/resourcemanager.folderViewer",
        "roles/iap.tunnelResourceAccessor",
        "roles/compute.osLogin",
        "roles/artifactregistry.writer",
        "roles/container.admin",
        "roles/compute.instanceAdmin",
        "roles/monitoring.editor",
        "roles/logging.admin"
      ]
    },
    "developer" = {
      group = "gcp-developers"
      roles = [
        "roles/viewer",
        "roles/resourcemanager.organizationViewer",
        "roles/resourcemanager.folderViewer",
        "roles/compute.osLogin",
        "roles/artifactregistry.writer",
        "roles/container.clusterAdmin",
        "roles/container.developer",
        "roles/monitoring.viewer",
        "roles/logging.viewer"
      ]
    },
    "tester" = {
      group = "gcp-testers"
      roles = [
        "roles/viewer",
        "roles/resourcemanager.organizationViewer",
        "roles/resourcemanager.folderViewer",
        "roles/compute.osLogin",
        "roles/artifactregistry.writer",
        "roles/container.developer",
        "roles/monitoring.viewer",
        "roles/logging.viewer"
      ]
    },
    "automation" = {
      group = "gcp-automation"
      roles = [
        "roles/artifactregistry.writer",
        "roles/container.viewer"
      ]
    }
  }

  # Defines the default APIs to enable for the IaC project
  default_apis_iac_project = [
    "logging.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iap.googleapis.com",
    "serviceusage.googleapis.com",
    "iam.googleapis.com",
    "orgpolicy.googleapis.com"
  ]

  # Defines the default labels for the IaC project
  default_labels = {
    "terraform_managed" = "true"
    "environment"       = "all"
  }

  # Others
  organization_name = var.organization_name == null ? split(".", data.google_organization.this.domain)[0] : var.organization_name
}

data "google_organization" "this" {
  organization = "organizations/${var.organization_id}"
}

# Main project for the resources:
module "iac_project" {
  source  = "terraform-google-modules/project-factory/google"
  version = "= 18.0.0"

  name                     = "${local.organization_name}-prj-all-iac"
  org_id                   = var.organization_id
  billing_account          = var.billing_account
  activate_apis            = concat(local.default_apis_iac_project, var.extra_apis_iac_project)
  random_project_id_length = 4
  deletion_policy          = var.project_deletion_policy
  labels = merge(
    local.default_labels,
    var.extra_labels
  )
  auto_create_network = false
}

# GCS for remote-backend:
resource "google_storage_bucket" "tfstate" {
  name     = "${local.organization_name}-gcs-all-iac"
  location = "EU"
  project  = module.iac_project.project_id

  force_destroy               = true
  public_access_prevention    = "enforced"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }
  labels = merge(local.default_labels, var.extra_labels)
}

# Organization IAM for default groups:
resource "google_organization_iam_member" "default_groups" {
  for_each = {
    for iam_member in flatten([
      for group_name, group in local.iam_groups : [
        for role in group.roles : {
          member = "group:${group.group}@${data.google_organization.this.domain}"
          role   = role
        }
      ]
    ]) : "${iam_member.role}-${iam_member.member}" => iam_member
  }
  org_id = var.organization_id
  role   = each.value.role
  member = each.value.member
}
