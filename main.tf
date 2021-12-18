terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

provider "cloudflare" {
  email   = var.cloudflare_email # export CLOUDFLARE_API_KEY 
  api_key = var.cloudflare_api_key # export CLOUDFLARE_API_TOKEN
}

# resource "cloudflare_argo_tunnel" "example" {
#   account_id = "d41d8cd98f00b204e9800998ecf8427e"
#   name       = "my-tunnel"
#   secret     = "dGVzdA==" # Base64 secret
# }

# terraform import cloudflare_argo_tunnel.example ACCOUNT_D/ID

resource "cloudflare_access_application" "staging_app" {
  zone_id                   = "1d5fdc9e88c8a8c4518b068cd94331fe"
  name                      = "staging application"
  domain                    = "staging.example.com"
  type                      = "self_hosted"
  session_duration          = "24h"
  auto_redirect_to_identity = false
}

# Allowing access to `test@example.com` email address only
resource "cloudflare_access_policy" "test_policy_allow" {
  application_id = cloudflare_access_application.id
  zone_id        = "d41d8cd98f00b204e9800998ecf8427e" // optional
  name           = "staging policy"
  precedence     = "1"
  decision       = "allow"

  include {
    service_token = [cloudflare_access_service_token.demo.id]
  }

  exclude {
    email = ["test@example.com"]
  }

  require {
    email = ["test@example.com"]
  }
}

resource "cloudflare_access_policy" "test_policy_block" {
  application_id = cloudflare_access_application.id
  zone_id        = "d41d8cd98f00b204e9800998ecf8427e" // optional
  name           = "staging policy"
  precedence     = "2"
  decision       = "block"

  # see https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/access_group#conditions for policy details
  include {
    everyone = true
  }

  exclude {
    group = [cloudflare_access_group.demo.id]
  }
}

resource "cloudflare_access_service_token" "demo" {
  account_id = "d41d8cd98f00b204e9800998ecf8427e"
  name       = "CI/CD app renewed"

  min_days_for_renewal = 30

  # This flag is important to set if min_days_for_renewal is defined otherwise 
  # there will be a brief period where the service relying on that token 
  # will not have access due to the resource being deleted
  lifecycle {
    create_before_destroy = true
  }
}
