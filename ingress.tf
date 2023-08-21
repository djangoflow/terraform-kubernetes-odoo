resource "kubernetes_ingress_v1" "ingress" {
  depends_on = [module.deployment, kubernetes_namespace_v1.namespace, random_string.ingress-name]
  for_each   = merge({
    origin : {
      hostname = local.ingress_hostname
      domain   = var.ingress_domain
      dbfilter = ""
    }
  }, var.ingress)
  metadata {
    name        = "${var.name}-odoo-ingress-${lookup(each.value, "hostname", each.key)}"
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
      "nginx.ingress.kubernetes.io/configuration-snippet" : <<EOT
          proxy_set_header X-Odoo-Dbfilter  '${lookup(each.value, "dbfilter", "")}';
      EOT
    }
  }
  spec {
    tls {
      hosts       = [local.ingress_hostname, lookup(each.value, "hostname", each.key)]
      secret_name = "${var.name}-${lookup(each.value, "hostname", each.key)}-letsencrypt"
    }
    rule {
      host = lookup(each.value, "hostname", each.key)
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
                number = "8072"
              }
            }
          }
        }
        path {
          path = "/websocket"
          backend {
            service {
              name = "${var.name}-odoo"
              port {
                number = "8072"
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
