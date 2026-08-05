Terraform
=========

https://developer.hashicorp.com/terraform/docs
https://www.geeksforgeeks.org/devops/what-is-terraform/

# variables
terraform.tfvars

# main (group and roles)
main.tf

# terraform versions
versions.tf

# gcloud login is required for IaC (optionally, covered within ~/scripts/set_gcp_environment.sh)
# gcloud auth application-default --no-launch-browser or gcloud auth login --update-adc --no-launch-browser

# initialize terraform modules
terraform init

# review terraform plan (what would be applied)
terraform plan -no-color

# apply (after terraform plan has been reviewed)
terraform apply
