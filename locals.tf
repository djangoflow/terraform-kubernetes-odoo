resource "random_string" "ingress-name" {
  length  = 16
  special = false
}

locals {
  ingress_hostname = lower("${random_string.ingress-name.result}.${var.ingress_domain}")
  hostnames        = coalesce(var.hostnames, {for k, v in var.ingress : k => v.domain})
  ingress          = coalesce(var.ingress, var.hostnames != null ? {
  for k, v in var.hostnames : k => {
    domain = v, dbfilter = null
  }
  } : null)

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
