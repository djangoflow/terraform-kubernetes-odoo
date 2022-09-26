data "google_sql_database_instance" "db_instance" {
  count = var.db.instance != null ? 1 : 0
  name  = var.db.instance
}

resource "google_sql_database" "db" {
  count    = var.db.instance != null && var.db.name != null ? 1 : 0
  instance = var.db.instance
  name     = var.db.name
}

resource "google_sql_user" "db_user" {
  count    = var.db.instance != null && var.db.user != null ? 1 : 0
  instance = var.db.instance
  name     = var.db.user
  password = coalesce(var.db.password, random_password.db_password.0.result)
}

resource "random_password" "db_password" {
  count   = var.db.instance != null  && var.db.password == null? 1 : 0
  length  = 16
  special = false
}
