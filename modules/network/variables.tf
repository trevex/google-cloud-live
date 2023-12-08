variable "name" {
  type = string
}

variable "subnetworks" {
  type = list(object({
    name_affix    = string
    region        = string
    ip_cidr_range = string
    secondary_ip_range = list(object({
      range_name    = string
      ip_cidr_range = string
    }))
  }))
}

variable "private_service_access" {
  type = object({
    enabled       = optional(string, false)
    prefix_length = optional(number, 16)
  })
  default = {}
}
