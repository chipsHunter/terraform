terraform {
  required_providers {
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
    key    = "conf/dev/terraform.tfstate"

    skip_region_validation      = true
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }
}

provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = var.service_account_key_file
  zone                     = var.zone
}

resource "yandex_vpc_network" "my_net" {
  name = var.vpc_network_name
}

resource "yandex_vpc_subnet" "all_subnets" {
  for_each = var.subnets

  v4_cidr_blocks = [each.value.cidr_block]
  name           = each.value.name

  zone       = var.zone
  network_id = yandex_vpc_network.my_net.id
}
