# terraform-kubernetes-odoo
Opinionated Odoo deployment to GCP / GKE


### You need to provide/crate  a storage class if you want Odoo persistence, for example GKE SSD:
```
resource "kubernetes_manifest" "storage-class" {
  manifest = {
    apiVersion : "storage.k8s.io/v1",
    kind : "StorageClass",
    metadata : {
      name : "pd-ssd"
    }
    provisioner : "kubernetes.io/gce-pd",
    parameters : {
      type : "pd-ssd"
    }
    reclaimPolicy : "Delete"
    volumeBindingMode : "Immediate"
  }
}
```
