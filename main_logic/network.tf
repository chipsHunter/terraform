resource "yandex_vpc_network" "my_net" {
  name = var.vpc_network_name
}

# спросить, как бы тут на моем месте сделали
resource "yandex_vpc_subnet" "private_subnets" {
  for_each = {
    for k, v in var.subnets : k => v if k != "public"
  }

  v4_cidr_blocks = [each.value.cidr_block]
  name           = each.value.name
  zone           = var.zone
  network_id     = yandex_vpc_network.my_net.id
  route_table_id = yandex_vpc_route_table.rt.id
}

resource "yandex_vpc_subnet" "public_subnet" {
  v4_cidr_blocks = [var.subnets["public"].cidr_block]
  name           = var.subnets["public"].name
  zone           = var.zone
  network_id     = yandex_vpc_network.my_net.id
}

#-----------NAT-------------------------#
resource "yandex_vpc_gateway" "nat_gateway" {
  folder_id = var.folder_id
  name      = var.nat_gateway_name
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "rt" {
  folder_id  = var.folder_id
  name       = var.route_table_with_nat_name
  network_id = yandex_vpc_network.my_net.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}

#-------------Security Groups---------------#
resource "yandex_vpc_security_group" "app_security_group" {
  name       = var.sg_app_name
  network_id = yandex_vpc_network.my_net.id
  ingress {
    protocol          = "ANY"
    description       = "Allow incoming traffic from members of the same security group"
    from_port         = 0
    to_port           = 65535
    predefined_target = "self_security_group"
  }

  egress {
    protocol       = "ANY"
    description    = "Allow outgoing traffic"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
