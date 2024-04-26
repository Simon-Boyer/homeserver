variable "users" {
  type = map(object({
    disabled = optional(bool, false),
    displayname = string,
    email = string,
    admin = optional(bool, false),
  }))
}

variable "base_domain" {
  type = string
}

variable "letsencrypt_email" {
  type = string
}

variable "compartment_ocid" {
  type = string
}

variable "availability_domain" {
  type = string
}

variable "authorized_keys" {
  type = list(string)
}

variable "cidr_range" {
    type = string
    default = "10.0.0.0/16"
}

variable "cloudflare_zone_id" {
  type = string
}

variable "cloudflare_token" {
  type = string
  sensitive = true
}