terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "cloudflare_zones" "zones" {
  filter {}
}

locals {
  zones = {for zone in data.cloudflare_zones.zones.zones : zone.name => zone.id}
}

resource "cloudflare_record" "cname" {
  for_each = var.hostnames
  name     = each.key
  type     = "CNAME"
  proxied  = false
  value    = aws_cloudfront_distribution.cdn.domain_name
  zone_id  = local.zones[each.value]
  lifecycle {
    ignore_changes = [zone_id]
  }
}
