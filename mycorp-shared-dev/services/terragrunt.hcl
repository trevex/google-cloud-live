terraform {
  source = "../../modules/services"
}

include {
  path = find_in_parent_folders()
}

inputs = {
  enabled_apis = [
    "compute.googleapis.com",
    "container.googleapis.com",
    "servicenetworking.googleapis.com", # required for Private Service Access
  ]
}

