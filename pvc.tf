resource "kubernetes_persistent_volume_claim_v1" "data" {
  depends_on = [kubernetes_namespace_v1.namespace]
  metadata {
    name      = coalesce(var.pvc_name, "${var.name}-odoo")
    namespace = var.namespace
  }
  spec {
    storage_class_name = var.storage_class
    access_modes       = [
      "ReadWriteOnce"
    ]
    resources {
      requests = {
        storage = var.storage_size
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim_v1" "extra" {
  count      = length(var.odoo_addons_github_repo) > 0 ? 1 : 0
  depends_on = [kubernetes_namespace_v1.namespace]

  metadata {
    name      = "${var.name}-extra"
    namespace = var.namespace
  }
  spec {
    storage_class_name = var.storage_class
    access_modes       = [
      "ReadWriteOnce"
    ]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
  }
}
