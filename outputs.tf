output "backup_url" {
  value = "${var.name}-odoo-simple.${var.namespace}.svc.cluster.local/web/database/backup"
}
