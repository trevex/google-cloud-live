terraform {
  source = "../../modules//network"
}

include {
  path = find_in_parent_folders()
}

dependency "services" {
  config_path  = "../services"
  skip_outputs = true
}

# NOTE: Make sure to plan your CIDR ranges properly and stick to RFC1918 ranges
inputs = {
  name = "network-default"
  subnetworks = [{
    name_affix    = "main" # full name will be `${name}-${name_affix}-${region}`
    ip_cidr_range = "10.0.0.0/16"
    region        = "europe-west3"
    secondary_ip_range = [{
      range_name    = "pods"
      ip_cidr_range = "172.16.0.0/12"
      }, {
      range_name    = "services"
      ip_cidr_range = "172.32.0.0/16"
    }]
  }]
  private_service_access = {
    enabled       = true
    prefix_length = 18
  }
}
