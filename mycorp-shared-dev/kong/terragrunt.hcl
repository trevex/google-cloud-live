terraform {
  source = "../../modules//kong"
}

include {
  path = find_in_parent_folders()
}

dependency "cluster" {
  config_path = "../cluster"
}

inputs = {
  cluster       = dependency.cluster.outputs
  chart_version = "v0.10.0"
}
