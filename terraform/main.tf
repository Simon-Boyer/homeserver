resource "tls_private_key" "tf_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "oci_objectstorage_namespace" "bucket_namespace" {
  compartment_id = var.compartment_ocid
}

resource "oci_objectstorage_bucket" "images_bucket" {
  #Required
  compartment_id = var.compartment_ocid
  name           = "vm-images"
  namespace      = data.oci_objectstorage_namespace.bucket_namespace.namespace
}

module "omni-authentik-vm" {
  source                  = "git::https://codeberg.org/CodeGameEat/homeserver-terraform-modules.git//omni-authentik-vm-tfmodule?ref=v0.2"
  authorized_keys         = var.authorized_keys
  availability_domain     = var.availability_domain
  subnet_cidr             = cidrsubnet(var.cidr_range, 8, 0)
  vm_ocpus                = 2
  vm_memory_in_gbs        = 12
  vm_boot_volume_gb       = 100
  cloudflare_zone_id      = var.cloudflare_zone_id
  cloudflare_token        = var.cloudflare_token
  letsencrypt_email       = var.letsencrypt_email
  omni_name               = "arm-omni"
  tf_ssh_key              = tls_private_key.tf_ssh_key
  base_domain             = var.base_domain
  compartment_ocid        = var.compartment_ocid
  images_bucket           = oci_objectstorage_bucket.images_bucket.name
  images_bucket_namespace = data.oci_objectstorage_namespace.bucket_namespace.namespace
}

data "authentik_group" "admins" {
  depends_on = [module.omni-authentik-vm]
  name       = "authentik Admins"
}

resource "random_password" "authentik_default_passwords" {
  for_each = var.users
  length   = 32
  special  = true
}

resource "authentik_user" "users" {
  depends_on = [module.omni-authentik-vm]
  for_each   = var.users
  username   = each.key
  name       = each.value.displayname
  email      = each.value.email
  groups     = each.value.admin ? [data.authentik_group.admins.id] : []
  password   = random_password.authentik_default_passwords[each.key].result # init password, changing the password 
  # in authentik will not trigger an update here. 
}

output "authentik_init_passwords" {
  value     = random_password.authentik_default_passwords
  sensitive = true
}

