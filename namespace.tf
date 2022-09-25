resource "kubernetes_namespace_v1" "namespace" {
  count = var.namespace_create ? 1 : 0
  metadata {
    name = var.namespace
  }
}
