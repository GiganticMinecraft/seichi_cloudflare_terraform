terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
  backend "remote" {
    organization = "test-org"

    workspaces {
      name = "test-work"
    }
  }
}

locals {
  cloudflare_zone_id = "77c10fdfa7c65de4d14903ed8879ebcb"
  root_domain = "seichi.click"
}

provider "cloudflare" {
  email   = var.cloudflare_email
  api_key = var.cloudflare_api_key
}
