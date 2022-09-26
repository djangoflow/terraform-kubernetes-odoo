terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.0"
    }
  }
}

data "cloudflare_zones" "zones" {
  filter {}
}

locals {
  zones = {for zone in data.cloudflare_zones.zones.zones : zone.name => zone.id}
}

resource "cloudflare_record" "a" {
  name = local.ingress_hostname
  type = "A"
  proxied = false
  value = kubernetes_ingress_v1.ingress.status.0.load_balancer.0.ingress.0.ip
  zone_id = local.zones[coalesce(var.ingress_domain, values(var.hostnames)[0])]
  depends_on = [kubernetes_ingress_v1.ingress]
  lifecycle {
    ignore_changes = [zone_id]
  }
}
