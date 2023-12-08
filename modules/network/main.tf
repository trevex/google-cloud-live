resource "google_compute_network" "network" {
  name                    = var.name
  auto_create_subnetworks = false
}

locals {
  # We precompute the subnetwork names to have unique identifiers in terraform state
  subnets_map = { for s in var.subnetworks : "${var.name}-${s.name_affix}-${s.region}" => s }
  # Let's collect all regions we are using
  regions = toset([for s in var.subnetworks : s.region])
}

# Let's create the specified subnetworks
resource "google_compute_subnetwork" "subnetworks" {
  #checkov:skip=CKV_GCP_26:We do not use VPC Flow Logs in this demo
  for_each = local.subnets_map
  name     = each.key
  network  = google_compute_network.network.id
  region   = each.value.region

  private_ip_google_access   = true
  private_ipv6_google_access = "ENABLE_OUTBOUND_VM_ACCESS_TO_GOOGLE"
  ip_cidr_range              = each.value.ip_cidr_range
  purpose                    = "PRIVATE"

  secondary_ip_range = each.value.secondary_ip_range
}

# And for each region we create a router and make sure NAT is set up
resource "google_compute_router" "router" {
  for_each = local.regions
  name     = "${var.name}-${each.value}"
  network  = google_compute_network.network.id
  region   = each.value
}

resource "google_compute_router_nat" "router_nat" {
  for_each = local.regions
  name     = "${var.name}-${each.value}"
  router   = google_compute_router.router[each.key].name
  region   = each.value

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# If Private Service Access (PSA) is enabled,
# let's reserve IPs for peering (for private access to GCP services)
resource "google_compute_global_address" "services_private_ips" {
  count = var.private_service_access.enabled ? 1 : 0

  name          = "services-private-ips"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = var.private_service_access.prefix_length
  network       = google_compute_network.network.id
}

# Let create a peering connection to the service network
resource "google_service_networking_connection" "services_private" {
  count = var.private_service_access.enabled ? 1 : 0

  network                 = google_compute_network.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.services_private_ips[0].name]
}

# Let's make sure we export and import routes to ensure connectivity
resource "google_compute_network_peering_routes_config" "services_private" {
  count = var.private_service_access.enabled ? 1 : 0

  peering              = google_service_networking_connection.services_private[0].peering
  network              = google_compute_network.network.name
  import_custom_routes = true
  export_custom_routes = true
}
