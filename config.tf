resource "kubernetes_config_map" "odoo_config" {
  depends_on = [kubernetes_namespace_v1.namespace]
  metadata {
    name      = "${var.name}-odoo-config"
    namespace = var.namespace
  }
  data = {
    "odoo.conf" : var.odoo_config
  }
}
