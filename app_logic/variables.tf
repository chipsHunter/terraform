
variable "zone" {
  default = "ru-central1-a"
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Folder ID"
  type        = string
}
variable "kube_config" {
  description = "Path to k3s config from Java App instance"
  type        = string
}
variable "service_account_key_file" {
  description = "Path to Service Account terraform-lab key file"
  type        = string
}
variable "postgres_cluster_pass" {
  type = string
}
variable "redis_password" {
  type = string
}

# портами светить некруто, что-то бы с этим сделать
locals {
  backend_env = {
    POSTGRES_HOST     = data.terraform_remote_state.infra.outputs.cluster_fqdn
    POSTGRES_PORT     = 6432
    POSTGRES_USER     = data.terraform_remote_state.infra.outputs.database_user
    POSTGRES_PASSWORD = var.postgres_cluster_pass
    POSTGRES_DB       = data.terraform_remote_state.infra.outputs.database_name

    REDIS_HOST     = data.terraform_remote_state.infra.outputs.redis_ipv4
    REDIS_PORT     = 6379
    REDIS_PASSWORD = var.redis_password

    FLUENTD_ENABLED = false
    FLUENTD_HOST    = "localhost"
    FLUENTD_PORT    = 24224

    SERVER_PORT = 8081
    DEBUG       = true
  }
}

variable "chart_repo_settings" {
  type = map(object({
    name    = string
    chart   = string
    version = string
  }))
}

variable "iam_token" {
  type      = string
  sensitive = true
}
variable "kuber_target_host_name" {
  type = string
}
variable "backend_group" {
  description = "Params of back&front backend groups"
  type = map(object({
    name = string
    port = number
    path = string
  }))
}
