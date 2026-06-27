output "iac_bucket_name" {
  value = google_storage_bucket.tfstate.name
}

output "iac_project_id" {
  value = module.iac_project.project_id
}

output "iac_project_number" {
  value = module.iac_project.project_number
}

output "iac_project_name" {
  value = module.iac_project.project_name
}

output "billing_account" {
  value = var.billing_account
}

output "organization_id" {
  value = var.organization_id
}

output "region" {
  value = var.region
}

output "org_domain" {
  value = data.google_organization.this.domain
}

output "organization_name" {
  value = local.organization_name
}

output "iam_groups" {
  value = {
    for key, value in local.iam_groups :
    key => "${value.group}@${data.google_organization.this.domain}"
  }
}