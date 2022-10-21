output "backup_url" {
  value = "${var.name}-odoo.${var.namespace}.svc.cluster.local/web/database/backup"
}
