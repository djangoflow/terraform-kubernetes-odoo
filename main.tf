module "cloudfront" {
  depends_on = [cloudflare_record.a]
  source = "./modules/cloudfront-cloudflare"
  hostnames  = var.hostnames
  origin_hostname = cloudflare_record.a.hostname
}
