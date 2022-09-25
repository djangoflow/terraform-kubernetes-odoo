resource "kubernetes_persistent_volume_claim_v1" "data" {
  depends_on = [kubernetes_namespace_v1.namespace]
  metadata {
    name = "${var.name}-odoo"
    namespace = var.namespace
  }
  spec {
    storage_class_name = var.storage_class
    access_modes = [
      "ReadWriteOnce"
    ]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }
}
