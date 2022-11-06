module "cloudfront" {
  depends_on      = [cloudflare_record.a]
  source          = "./modules/cloudfront-cloudflare"
  hostnames       = local.hostnames
  origin_hostname = cloudflare_record.a.hostname
}
