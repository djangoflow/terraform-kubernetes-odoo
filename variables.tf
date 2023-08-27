variable "ingress" {
  description = "A map of hostname:ingress objects "
  type        = map(object({
    dbfilter = optional(string, "")
    domain   = string
  }))
  default = null
}

variable "ingress_domain" {
  description = "The domain name where the random (non-cached) origin hostname will be generated"
  type        = string
}

variable "update_strategy" {
  description = "The update strategy for the deployment"
  default     = "Recreate"
}

variable "name" {
  type        = string
  description = "The name for this deployment"
}

variable "namespace" {
  default = "odoo"
}

variable "namespace_create" {
  default = true
}

variable "storage_size" {
  default = "10Gi"
}

variable "storage_class" {
  default = "pd-ssd"
}

variable "image_name" {
  type = string
}

variable "image_tag" {
  type = string
}

variable "image_pull_policy" {
  type        = string
  default     = "IfNotPresent"
  description = "Pull policy for the images"
}

variable "helm_timeout" {
  default = 600
}


variable "db" {
  type = object({
    name     = optional(string)
    host     = optional(string)
    user     = optional(string)
    password = optional(string)
    instance = optional(string)
  })
}

variable "extra_env" {
  default = {}
}

variable "extra_secrets" {
  default = {}
}

variable "pvc_name" {
  default = null
}

variable "limits" {
  default = {}
}

variable "command" {
  type    = list(string)
  default = null
}

variable "args" {
  type    = list(string)
  default = null
}

variable "odoo_config" {
  type    = string
  default = <<EOT
[options]
addons_path = /mnt/extra-addons
data_dir = /var/lib/odoo
; admin_passwd =
; csv_internal_sep = ,
; db_maxconn = 64
;db_name =
; db_template = template1
; dbfilter = .*
; debug_mode = False
; email_from = False
; limit_memory_hard = 2684354560
; limit_memory_soft = 2147483648
limit_request = 8192
limit_time_cpu = 120
limit_time_real = 360
list_db = True
; log_db = False
log_handler = :WARN
;log_level = info
; logfile = None
longpolling_port = 8072
max_cron_threads = 1
; osv_memory_age_limit = 1.0
; osv_memory_count_limit = False
proxy_mode = True
server_wide_modules = web, logging_gke
; smtp_password = False
; smtp_port = 25
; smtp_server = localhost
; smtp_ssl = False
; smtp_user = False
workers = 4
; xmlrpc = True
; xmlrpc_interface =
; xmlrpc_port = 8069
; xmlrpcs = True
; xmlrpcs_interface =
; xmlrpcs_port = 8071
EOT
}

variable "readiness_probe" {
  type = object({
    http_get = object({
      path   = string
      port   = number
      scheme = string
    })
    success_threshold     = number
    failure_threshold     = number
    initial_delay_seconds = number
    period_seconds        = number
    timeout_seconds       = number
  })
  description = "Readiness probe for containers which have ports"
  default     = {
    http_get = {
      path   = "/web/database/manager"
      port   = 8069
      scheme = "HTTP"
    }
    success_threshold     = 1
    failure_threshold     = 5
    initial_delay_seconds = 30
    period_seconds        = 30
    timeout_seconds       = 5
  }
}

variable "liveness_probe" {
  type = object({
    http_get = object({
      path   = string
      port   = number
      scheme = string
    })
    success_threshold     = number
    failure_threshold     = number
    initial_delay_seconds = number
    period_seconds        = number
    timeout_seconds       = number
  })
  description = "Liveness probe for containers which have ports"
  default     = {
    http_get = {
      path   = "/web/database/manager"
      port   = 8069
      scheme = "HTTP"
    }
    success_threshold     = 1
    failure_threshold     = 5
    initial_delay_seconds = 30
    period_seconds        = 30
    timeout_seconds       = 5
  }
}

variable "extra_labels" {
  type        = map(string)
  default     = {}
  description = "Extra labels to add to generated objects"
}

variable "resources_requests_memory" {
  type    = string
  default = "1Gi"
}

variable "resources_requests_cpu" {
  type    = string
  default = "250m"
}

variable "resources_limits_memory" {
  type    = string
  default = "2Gi"
}

variable "resources_limits_cpu" {
  type    = string
  default = "1000m"
}

variable "service_account_name" {
  default     = ""
  type        = string
  description = "Service account name"
}

variable "odoo_addons_image_name" {
  default = ""
}

variable "odoo_addons_image_tag" {
  default = ""
}

variable "enable_env_postgres" {
  default = true
  description = "Provider PG* variables for seamless "
}

variable "velero_backup_databases" {
  description = "List of databases to backup with pg_dump and velero"
  type = list(string)
  default = []
}
