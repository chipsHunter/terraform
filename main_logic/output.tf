data "yandex_compute_image" "latest_ubuntu" {
  family = "ubuntu-2204-lts"
}

output "ubuntu_image" {
  value = data.yandex_compute_image.latest_ubuntu.description
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
