variable "environment" {
  description = "Deployment environment (e.g., dev, stage, prod)"
  type        = string
}

data "yandex_compute_image" "latest_ubuntu_2404" {
  family = "ubuntu-2404-lts"
}
locals {
  ubuntu_id                 = data.yandex_compute_image.latest_ubuntu_2404.id
  cluster_for_java_app_fqdn = data.yandex_mdb_postgresql_cluster.cluster-for-java-app.host[0].fqdn
  redis_address             = yandex_compute_instance.redis.network_interface[0].ip_address

  base_name = var.environment

  redis_inst_name   = "${local.base_name}-redis-inst"
  app_inst_name     = "${local.base_name}-app-inst"
  bastion_inst_name = "${local.base_name}-bastion-inst"
  vpc_network_name  = "${local.base_name}-net"

  nat_gateway_name              = "${local.base_name}-nat-gateway"
  route_table_with_nat_name     = "${local.base_name}-nat-route-table"
  sg_app_name                   = "${local.base_name}-allow-inbound-in-this-and-ssh-from-private-app-sg"
  sg_db_name                    = "${local.base_name}-allow-inbound-in-this-and-ssh-from-private-db-sg"
  sg_bastion_name               = "${local.base_name}-allow-ssh-from-any"
  sg_alb_name                   = "${local.base_name}-allow-80-from-any-and-app-subnet"
  ipv4_addr_static_bastion_name = "${local.base_name}-bastion-host_ip"
}
variable "s3_folder_name" {
  description = "Prefix for tfstate in S3 bucket"
  type        = string
}
variable "subnets" {
  description = "A map of subnets to create"
  type = map(object({
    cidr_block = string
    name       = string
  }))
}
variable "instance_params" {
  description = "All params for instance "
  type = map(object({
    name = string
    disk_params = object({
      name   = string
      size   = number
      type   = string
      cores  = number
      memory = number
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

variable "main_terraform_sa_id" {
  description = "ID of the main Service Account that runs all"
  type        = string
}
