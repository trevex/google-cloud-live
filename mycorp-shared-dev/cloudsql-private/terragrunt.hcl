terraform {
  source = "../cloudsql-private"
}

include {
  path = find_in_parent_folders()
}

dependency "network" {
  config_path = "../network"
}

inputs = {
  network_id = dependency.network.outputs.id
}
