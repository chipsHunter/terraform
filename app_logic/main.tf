
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }

  backend "s3" {
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    bucket = "hvorostina"
    region = "ru-central1"
    key    = "conf/app/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

# Читаем state-файл инфраструктуры (синтаксис endpoint исправлен)
data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "hvorostina"
    key    = "conf/dev/terraform.tfstate"
    region = "ru-central1"
    endpoints = {
      s3 = "https://storage.yandexcloud.net"
    }
    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "kubernetes" {
  config_path = var.kube_config
}


provider "helm" {
  kubernetes = {
    config_path = var.kube_config
  }
  registries = [{
    url      = "oci://cr.yandex/${data.terraform_remote_state.infra.outputs.registry_id}"
    username = "iam"
    password = var.iam_token
  }]
}

provider "yandex" {
  alias                    = "ycr"
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = var.service_account_key_file
  zone                     = var.zone
}
