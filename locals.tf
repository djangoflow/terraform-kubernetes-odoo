resource "random_string" "ingress-name" {
  length  = 16
  special = false
}

locals {
  host             = coalesce(var.db.host, var.db.instance != null ? data.google_sql_database_instance.db_instance.0.private_ip_address : null)
  user             = var.db.user
  password         = coalesce(var.db.password, var.db.instance != null ? random_password.db_password.0.result : null)
  ingress_hostname = lower("${random_string.ingress-name.result}.${var.ingress_domain}")
  env              = merge({
    HOST : local.host
    USER : local.user
  }, var.extra_env, var.enable_env_postgres ? {
    PGUSER : local.user
    PGHOST : local.host
  } : {})

  common_labels = merge(
    {
      "app.kubernetes.io/part-of" : var.name
      "app.kubernetes.io/managed-by" : "terraform"
    },
    var.extra_labels,
  )

  secret_env = merge({
    PASSWORD : local.password
  }, var.extra_secrets, var.enable_env_postgres ? {
    PGPASSWORD : local.password
  } : {})
  # DEPRECATED
  #  odoo_admin_password = coalesce(var.odoo_admin_password, random_password.random-odoo-password.result)
}
