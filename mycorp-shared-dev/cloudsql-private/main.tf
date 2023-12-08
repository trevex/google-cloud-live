variable "region" {
  type = string
}

variable "network_id" {
  type = string
}


resource "google_sql_database_instance" "cloudsql_private" {
  name             = "cloudsql-private"
  region           = var.region
  database_version = "POSTGRES_14"

  settings {
    tier = "db-f1-micro"
    ip_configuration {
      ipv4_enabled    = "false"
      private_network = var.network_id
    }
  }
  deletion_protection = false
}

# This is how redis would look like
# resource "google_redis_instance" "redis_private" {
#   name           = "redis-private"
#   tier           = "BASIC"
#   redis_version  = "REDIS_4_0"
#   display_name   = "Redis Private"
#   memory_size_gb = 1
#   region         = var.region
#
#   authorized_network = var.network_id
#   connect_mode       = "PRIVATE_SERVICE_ACCESS"
# }
