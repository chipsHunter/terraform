data "yandex_compute_image" "latest_ubuntu" {
  family = "ubuntu-2204-lts"
}

output "ubuntu_image" {
  value = data.yandex_compute_image.latest_ubuntu.description
}

output "created_subnets_info" {
  description = "Detailed information for each created subnet"
  value = {
    for key, subnet in yandex_vpc_subnet.all_subnets :
    key => {
      id         = subnet.id
      name       = subnet.name
      cidr_block = subnet.v4_cidr_blocks[0]
    }
  }
}
