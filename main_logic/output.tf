data "yandex_compute_image" "latest_ubuntu" {
  family = "ubuntu-2204-lts"
}

data "yandex_compute_image" "container_optimized_image" {
  family = "container-optimized-image"
}


output "ubuntu_image" {
  value = data.yandex_compute_image.latest_ubuntu.description
}

output "container_optimized_image" {
  value = data.yandex_compute_image.container_optimized_image.description
}

output "private_created_subnets_info" {
  description = "Detailed information for each private created subnet"
  value = {
    for key, subnet in yandex_vpc_subnet.private_subnets :
    key => {
      id         = subnet.id
      name       = subnet.name
      cidr_block = subnet.v4_cidr_blocks[0]
    }
  }
}
output "public_created_subnets_info" {
  description = "Detailed information for each public created subnet"
  value = {
    id         = yandex_vpc_subnet.public_subnet.id
    name       = yandex_vpc_subnet.public_subnet.name
    cidr_block = yandex_vpc_subnet.public_subnet.v4_cidr_blocks[0]
  }
}

output "gateway" {
  value = yandex_vpc_gateway.nat_gateway.id
}

data "yandex_vpc_security_group" "app_sg" {
  name = yandex_vpc_security_group.app_security_group.name
}
output "app_sg" {
  description = "Security Groups in folder"
  value = {
    id = data.yandex_vpc_security_group.app_sg.id
  }
}

data "yandex_vpc_security_group" "bastion_sg" {
  name = yandex_vpc_security_group.bastion_host_group.name
}
output "bastion_sg" {
  description = "Security Groups in folder"
  value = {
    id = data.yandex_vpc_security_group.bastion_sg.id
  }
}
output "bastion_nat_ip" {
  description = "Security Groups in folder"
  value = {
    ip = yandex_vpc_address.addr_static_bastion.external_ipv4_address[0].address
  }
}
output "bastion_internal_app_ip" {
  description = "IPv4 bastion host address in private app subnet"
  value = {
    ip_address = yandex_compute_instance.bastion.network_interface[1].ip_address
    cidr_block = yandex_vpc_subnet.private_subnets["private-app"].v4_cidr_blocks
  }
}
output "bastion_internal_db_ip" {
  description = "IPv4 bastion host address in private db subnet"
  value = {
    ip_address = yandex_compute_instance.bastion.network_interface[2].ip_address
    cidr_block = yandex_vpc_subnet.private_subnets["private-db"].v4_cidr_blocks
  }
}
output "bastion_public_ip" {
  description = "IPv4 bastion host address in public subnet"
  value = {
    ip_address = yandex_compute_instance.bastion.network_interface[0].ip_address
    cidr_block = yandex_vpc_subnet.public_subnet.v4_cidr_blocks
  }
}
