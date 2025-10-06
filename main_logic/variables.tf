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
variable "service_account_key_file" {
  description = "Terraform Service Account Key Path"
  type        = string
}

variable "s3_folder_name" {
  description = "Prefix for tfstate in S3 bucket"
  type        = string
}

data "yandex_compute_image" "latest_ubuntu_2404" {
  family = "ubuntu-2404-lts"
}
locals {
  ubuntu_id = data.yandex_compute_image.latest_ubuntu_2404.id
}

variable "vpc_network_name" {
  description = "VPC wth 3 subnets for inst, db & public traffic"
  type        = string
}
variable "subnets" {
  description = "A map of subnets to create"
  type = map(object({
    cidr_block = string
    name       = string
  }))
}
variable "ipv4_addr_static_bastion_name" {
  description = "Bastion Host IPv4 address"
  type        = string
}
variable "nat_gateway_name" {
  description = "NAT for instances in private nets"
  type        = string
}
variable "route_table_with_nat_name" {
  description = "Route table with static NAT route"
  type        = string
}
variable "sg_app_name" {
  description = "Name for app Security Group"
  type        = string
}
variable "sg_db_name" {
  description = "Name for db Security Group"
  type        = string
}
variable "sg_bastion_name" {
  description = "Name for bastion host Security Group"
  type        = string
}
variable "sg_alb_name" {
  description = "Name for ALB host Security Group"
  type        = string
}
variable "instance_redis" {
  description = "All params for instance with Redis installed"
  type = map(object({
    name = string
    disk_params = object({
      name = string
      size = number
      type = string
    })
    platform_id       = string
    ssh_key_file_path = string
  }))
}
variable "instance_bastion" {
  description = "All params for instance with Redis installed"
  type = map(object({
    name = string
    disk_params = object({
      name = string
      size = number
      type = string
    })
    platform_id       = string
    ssh_key_file_path = string
  }))
}
variable "instance_app" {
  description = "All params for instance with Redis installed"
  type = map(object({
    name = string
    disk_params = object({
      name = string
      size = number
      type = string
    })
    platform_id       = string
    ssh_key_file_path = string
  }))
}
variable "ip_cidr_allow_ssh_from" {
  description = "My IPv4 address to access Bastion Host"
  type        = list(string)
}
variable "script_dir" {
  description = "Path to Folder with scripts"
  type        = string
}
variable "registry_name" {
  description = "Name of Yandex Container Registry"
  type        = string
}
variable "OAuth_token" {
  description = "Token for external app access"
  type        = string
}
variable "database" {
  description = "All databases created"
  type = map(object({
    name  = string
    owner = string
  }))
}
variable "database_user" {
  type = map(object({
    name     = string
    password = string
  }))
}
variable "database_cluster" {
  type = map(object({
    name               = string
    environment        = string
    resource_preset_id = string
    disk_type_id       = string
    disk_size          = number
    version            = number
  }))
}

locals {
  cluster_for_java_app_fqdn = data.yandex_mdb_postgresql_cluster.cluster-for-java-app.host[0].fqdn
  redis_address             = yandex_compute_instance.redis.network_interface[0].ip_address
}

variable "main_terraform_sa_id" {
  description = "ID of the main Service Account that runs all"
  type        = string
}
