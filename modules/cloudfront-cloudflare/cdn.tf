resource "aws_cloudfront_distribution" "cdn" {
  depends_on = [
    aws_acm_certificate.cert,
  ]

  aliases = keys(var.hostnames)

  origin {
    origin_id   = "odoo"
    domain_name = var.origin_hostname
    custom_origin_config {
      origin_read_timeout    = 60
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = [
        "TLSv1.2"
      ]
    }
  }

  origin {
    origin_id   = "odoo-acme-resolver"
    domain_name = var.origin_hostname
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = [
        "TLSv1.2"
      ]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  retain_on_delete    = false
  wait_for_deployment = false

  dynamic "logging_config" {
    for_each = var.logging_bucket != null ? [1] : []
    content {
      include_cookies = false
      bucket          = var.logging_bucket
    }
  }

  default_cache_behavior {
    allowed_methods = [
      "DELETE",
      "GET",
      "HEAD",
      "OPTIONS",
      "PATCH",
      "POST",
      "PUT"
    ]
    cached_methods = [
      "GET",
      "HEAD"
    ]
    target_origin_id = "odoo"
    compress         = false

    forwarded_values {
      query_string            = true
      query_string_cache_keys = []
      headers                 = [
        "*"
      ]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }
  dynamic "ordered_cache_behavior" {
    for_each = toset([
      "*/static/*",
      "*/web/css/*",
      "*/web/js/*",
      "*/web/image*",
      "*/web/content*",
      "*/web/assets*",
      "*/website/image/*"
    ])
    content {
      path_pattern    = ordered_cache_behavior.key
      allowed_methods = [
        "GET",
        "HEAD",
        "OPTIONS"
      ]
      cached_methods = [
        "GET",
        "HEAD",
        "OPTIONS"
      ]
      target_origin_id = "odoo"

      forwarded_values {
        query_string = false
        headers      = [
          "Origin"
        ]

        cookies {
          forward = "none"
        }
      }

      min_ttl                = 0
      default_ttl            = 86400
      max_ttl                = 31536000
      compress               = true
      viewer_protocol_policy = "redirect-to-https"
    }
  }

  ordered_cache_behavior {
    path_pattern    = "/.well-known/acme-challenge/*"
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS"
    ]
    cached_methods = [
      "GET",
      "HEAD",
      "OPTIONS"
    ]
    target_origin_id = "odoo-acme-resolver"

    forwarded_values {
      query_string            = true
      query_string_cache_keys = []
      headers                 = [
        "*"
      ]
      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
      //      restriction_type = "whitelist"
      //      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate.cert.arn
    ssl_support_method             = "sni-only"
    cloudfront_default_certificate = false
  }
}
