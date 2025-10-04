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
variable "nat_gateway_name" {
  description = "NAT for instances in private nets"
  type        = string
}
variable "route_table_with_nat_name" {
  description = "Route table with static NAT route"
  type        = string
}
