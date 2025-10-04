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
