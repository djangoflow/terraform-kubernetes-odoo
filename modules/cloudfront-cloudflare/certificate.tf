resource "aws_acm_certificate" "cert" {
  domain_name               = keys(var.hostnames)[0]
  validation_method         = "DNS"
  subject_alternative_names = slice(keys(var.hostnames), 1, length(keys(var.hostnames)))
  #  provider                  = aws.virginia
  lifecycle {
    create_before_destroy = true
  }
}

resource "cloudflare_record" "aws_cname" {
  for_each = {
  for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
    name    = dvo.resource_record_name
    record  = trimsuffix(dvo.resource_record_value, ".")
    type    = dvo.resource_record_type
    zone_id = lookup(local.zones, dvo.domain_name,
      lookup(local.zones, regex("^[\\w-]+\\.(.+)$", dvo.domain_name)[0], "zone-id-not-found"))
  }
  }
  name    = each.value.name
  type    = each.value.type
  proxied = false
  value   = each.value.record
  zone_id = each.value.zone_id
  lifecycle {
    ignore_changes = [zone_id]
  }
}

output "domain_validation_options" {
  value = aws_acm_certificate.cert.domain_validation_options
}
