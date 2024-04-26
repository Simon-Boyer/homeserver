terraform {
  required_providers {
    gpg = {
      source = "Olivr/gpg"
      version = "0.2.1"
    }
    oci = {
      source = "oracle/oci"
      version = "5.31.0"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "4.25.0"
    }
    local = {
      source = "hashicorp/local"
      version = "2.4.1"
    }
    time = {
      source = "hashicorp/time"
      version = "0.10.0"
    }
    authentik = {
      source = "goauthentik/authentik"
      version = "2024.2.0"
    }
  }
}

provider "authentik" {
  token = module.omni-authentik-vm.authentik_token
  url = "https://authentik.${var.base_domain}"
  insecure = true
}
