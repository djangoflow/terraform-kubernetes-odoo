terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }
  }
}

module "cloudfront" {
  for_each        = var.ingress
  depends_on      = [cloudflare_record.a]
  source          = "./modules/cloudfront-cloudflare"
  hostnames       = { (each.key) : each.value.domain }
  origin_hostname = cloudflare_record.a.hostname
}
