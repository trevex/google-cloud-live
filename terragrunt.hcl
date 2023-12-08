locals {
  # Automatically load project-level and region-level variables, however
  # we need a fallback, because run-all needs to be able to evaluate the parent
  # terragrunt.hcl as well. (otherwise errors)
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl", "fallback.hcl"))
  region_vars  = read_terragrunt_config(find_in_parent_folders("region.hcl", "fallback.hcl"))

  env = merge(
    local.region_vars.locals,
    local.project_vars.locals,
  )

  # We provide a way to augment a terraform module with snippets.
  # An example for this is to provide an easy way to setup kubernetes- and helm-provider
  # for a specific cluster.
  #
  # Load addons.hcl, if available.
  addons_vars   = read_terragrunt_config("${get_terragrunt_dir()}/addons.hcl", {})
  addons_locals = lookup(local.addons_vars, "locals", {})
  # Optional addons
  cluster_variable = lookup(local.addons_locals, "cluster_variable", false)
  kube_providers   = lookup(local.addons_locals, "kube_providers", false)
}


terraform {
  # Force Terraform to keep trying to acquire a lock for
  # up to 20 minutes if someone else already has the lock
  extra_arguments "retry_lock" {
    commands  = get_terraform_commands_that_need_locking()
    arguments = ["-lock-timeout=20m"]
  }
}


generate "providers" {
  path      = "terragrunt_providers.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
provider "google" {
  project             = "${local.env.project}"
  region              = "${local.env.region}"
}
provider "google-beta" {
  project             = "${local.env.project}"
  region              = "${local.env.region}"
}


${local.cluster_variable ? <<EOF
variable "cluster" {
  type = object({
    name                  = string
    host                  = string
    ca_certificate        = string
    service_account_email = string
  })
}
EOF
  : ""}


${local.kube_providers ? <<EOF
data "google_client_config" "kube_providers" {}

provider "kubernetes" {
  host                   = var.cluster.host
  token                  = data.google_client_config.kube_providers.access_token
  cluster_ca_certificate = var.cluster.ca_certificate
}

provider "helm" {
  kubernetes {
    host                   = var.cluster.host
    token                  = data.google_client_config.kube_providers.access_token
    cluster_ca_certificate = var.cluster.ca_certificate
  }
}
EOF
: ""}

EOF
}

remote_state {
  backend = "gcs"
  config = {
    skip_bucket_creation = true
    bucket               = "nvoss-gcloud-live-tf-state"
    prefix               = path_relative_to_include()
  }
  generate = {
    path      = "terragrunt_backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Configure root level variables that all resources can inherit
inputs = {
  project = local.env.project
  region  = local.env.region
}

