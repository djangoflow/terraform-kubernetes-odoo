resource "random_string" "ingress-name" {
  length  = 16
  special = false
}

locals {
  ingress_domain   = coalesce(var.ingress_domain, values(var.hostnames)[0])
  ingress_hostname = lower("${random_string.ingress-name.result}.${local.ingress_domain}")

  env = merge({
    HOST : coalesce(var.db.host, var.db.instance != null ? data.google_sql_database_instance.db_instance.0.private_ip_address : null)
    USER : var.db.user
  }, var.extra_env)

  common_labels = merge(
    {
      "app.kubernetes.io/part-of" : var.name
      "app.kubernetes.io/managed-by" : "terraform"
    },
    var.extra_labels,
  )

  secret_env = {
    PASSWORD : coalesce(var.db.password, var.db.instance != null ? random_password.db_password.0.result : null)
  }
  # DEPRECATED
  #  odoo_admin_password = coalesce(var.odoo_admin_password, random_password.random-odoo-password.result)
}
