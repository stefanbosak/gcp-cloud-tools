# Mandatory:
variable "organization_id" {
  description = "The organization id"
  type        = string
}

variable "billing_account" {
  description = "The billing account id"
  type        = string
}

variable "region" {
  description = "Region"
  type        = string
}

# Optional:
variable "extra_apis_iac_project" {
  description = "Additional APIs to enable for the main project"
  type        = list(string)
  default     = []
}

variable "project_deletion_policy" {
  description = "Project deletion policy"
  type        = string
  default     = "PREVENT"
}

variable "extra_labels" {
  description = "Extra labels to add to the main project"
  type        = map(string)
  default     = {}
}

variable "organization_name" {
  description = "Organization name"
  type        = string
  default     = null
}
