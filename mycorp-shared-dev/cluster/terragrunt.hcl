terraform {
  source = "../../modules//cluster"
}

include {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  name                   = "cluster-default"
  network_id             = dependency.network.outputs.id
  subnetwork_id          = dependency.network.outputs.subnetworks["network-default-main-europe-west3"].id
  master_ipv4_cidr_block = "172.224.0.0/28" # avoid collision with ranges of network
}
