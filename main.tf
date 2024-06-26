module "cloudfront" {
  for_each        = var.ingress
  depends_on      = [cloudflare_record.a]
  source          = "djangoflow/cloudfront-odoo/aws"
  hostnames       = { (each.key) : each.value.domain }
  origin_hostname = cloudflare_record.a.hostname
}
