module "deployment" {
  source     = "djangoflow/deployment/kubernetes"
  version    = ">=2.5.2"
  depends_on = [kubernetes_namespace_v1.namespace, kubernetes_config_map.odoo_config, kubernetes_secret_v1.secrets]

  #  pre_install_job_command = ["odoo", "--stop-after-init", "--no-http", .....]

  init_user_image_name = var.odoo_addons_image_name
  init_user_image_tag  = var.odoo_addons_image_tag

  object_prefix                 = "${var.name}-odoo"
  replicas                      = 1
  command                       = var.command
  arguments                     = var.args
  image_name                    = var.image_name
  image_tag                     = var.image_tag
  pull_policy                   = var.image_pull_policy
  namespace                     = var.namespace
  readiness_probe_enabled       = true
  readiness_probe_path          = var.readiness_probe.http_get.path
  readiness_probe_port          = var.readiness_probe.http_get.port
  readiness_probe_scheme        = var.readiness_probe.http_get.scheme
  readiness_probe_initial_delay = var.readiness_probe.initial_delay_seconds
  readiness_probe_timeout       = var.readiness_probe.timeout_seconds
  readiness_probe_failure       = var.readiness_probe.failure_threshold
  readiness_probe_success       = var.readiness_probe.success_threshold
  liveness_probe_enabled        = true
  liveness_probe_path           = var.liveness_probe.http_get.path
  liveness_probe_port           = var.liveness_probe.http_get.port
  liveness_probe_scheme         = var.liveness_probe.http_get.scheme
  liveness_probe_initial_delay  = var.liveness_probe.initial_delay_seconds
  liveness_probe_timeout        = var.liveness_probe.timeout_seconds
  liveness_probe_failure        = var.liveness_probe.failure_threshold
  liveness_probe_success        = var.liveness_probe.success_threshold
  startup_probe_enabled         = false
  security_context_enabled      = true
  env                           = local.env
  resources_limits_cpu          = var.resources_limits_cpu
  resources_limits_memory       = var.resources_limits_memory
  resources_requests_cpu        = var.resources_requests_cpu
  resources_requests_memory     = var.resources_requests_memory

  service_account_name = var.service_account_name
  labels               = merge(local.common_labels, {
    "app.kubernetes.io/instance" = "${var.name}-odoo"
    "app.kubernetes.io/version"  = var.image_tag
  })
  template_labels = {
    "backup.velero.io/backup-volumes" = "data"
  }
  env_secret = [
    for k, v in    local.secret_env : {
      secret = "${var.name}-odoo-secrets"
      name   = k
      key    = k
    }
  ]
  ports = [
    {
      name           = "http"
      protocol       = "TCP"
      container_port = 8069
      service_port   = "80"
    },
    {
      name           = "longpolling"
      protocol       = "TCP"
      container_port = 8072
      service_port   = "8072"
    }
  ]
  security_context_uid = 101
  security_context_gid = 101
  volumes              = concat([
    {
      name        = "data"
      type        = "persistent_volume_claim"
      object_name = kubernetes_persistent_volume_claim_v1.data.metadata.0.name
      readonly    = false
      mounts      = [
        {
          mount_path = "/var/lib/odoo"
        }
      ]
    },
    {
      name        = "config"
      type        = "config_map"
      object_name = kubernetes_config_map.odoo_config.metadata.0.name
      readonly    = true
      mounts      = [
        {
          mount_path = "/etc/odoo/odoo.conf"
          sub_path   = "odoo.conf"
        }
      ]
    },
  ], length(var.odoo_addons_image_name) > 0 ? [
    {
      name     = "extra-addons"
      type     = "empty_dir"
      readonly = false
      mounts   = [
        {
          mount_path = "/mnt/extra-addons"
        }
      ]
    }
  ] : [])
  update_strategy = var.update_strategy
  # Not really needed for Odoo
  #  node_selector = {
  #    "iam.gke.io/gke-metadata-server-enabled" = "true"
  #  }
}
