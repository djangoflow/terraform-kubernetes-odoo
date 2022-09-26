resource "kubernetes_ingress_v1" "ingress" {
  depends_on = [module.deployment, kubernetes_namespace_v1.namespace]
  metadata {
    name        = "${var.name}-odoo-ingress"
    namespace   = var.namespace
    annotations = {
      "kubernetes.io/ingress.class"                         = "nginx"
      "nginx.ingress.kubernetes.io/tls-acme"                = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size"         = "90m"
      "nginx.ingress.kubernetes.io/ssl-redirect"            = "true"
      "nginx.ingress.kubernetes.io/proxy-read-timeout"      = "180s"
      "nginx.ingress.kubernetes.io/proxy-write-timeout"     = "180s"
      "nginx.ingress.kubernetes.io/proxy-connect-timeout"   = "180s"
      "nginx.ingress.kubernetes.io/worker-shutdown-timeout" = "300s"
      "cert-manager.io/cluster-issuer"                      = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/enable-cors"             = "true"
      "nginx.ingress.kubernetes.io/cors-allow-origin"       = "*"
      #      "nginx.ingress.kubernetes.io/configuration-snippet": <<EOT
      #    more_set_headers 'X-Frame-Options: ALLOWALL';
      #EOT
    }
  }
  spec {
    tls {
      hosts = concat(keys(var.hostnames), [
        local.ingress_hostname
      ])
      secret_name = "${var.name}-letsencrypt"
    }
    dynamic "rule" {
      for_each = merge(var.hostnames, {
        (local.ingress_hostname) : local.ingress_domain
      })
      content {
        host = rule.key
        http {
          path {
            path = "/"
            backend {
              service {
                name = "${var.name}-odoo"
                port {
                  number = "80"
                }
              }
            }
          }
          path {
            path = "/longpolling"
            backend {
              service {
                name = "${var.name}-odoo"
                port {
                  number   = "8072"
                }
              }
            }
          }
          path {
            path = "/web/database"
            backend {
              service {
                name = "service-does-not-exist"
                port {
                  number = "80"
                }
              }
            }
          }
        }
      }
    }
  }
}
