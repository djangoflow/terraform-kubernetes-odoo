resource "random_string" "ingress-name" {
  length  = 16
  special = false
}

locals {
  ingress-domain   = values(var.hostnames)[0]
  ingress-hostname = lower("${random_string.ingress-name.result}.${local.ingress-domain}")

  env = merge({
    HOST : var.db.host
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
    PASSWORD : var.db.password
  }
  # DEPRECATED
  #  odoo_admin_password = coalesce(var.odoo_admin_password, random_password.random-odoo-password.result)
}
