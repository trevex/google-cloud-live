resource "google_project_service" "services" {
  for_each = var.enabled_apis
  project  = var.project
  service  = each.value
}
