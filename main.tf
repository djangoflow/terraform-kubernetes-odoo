module "cloudfront" {
  for_each        = var.ingress
  depends_on      = [cloudflare_record.a]
  source          = "./modules/cloudfront-cloudflare"
  hostnames       = { (each.key) : each.value.domain }
  origin_hostname = cloudflare_record.a.hostname
}
