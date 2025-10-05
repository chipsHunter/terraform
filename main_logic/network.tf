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
  name           = var.subnets["public"].name
  zone           = var.zone
  network_id     = yandex_vpc_network.my_net.id
  v4_cidr_blocks = [var.subnets["public"].cidr_block]
}

resource "yandex_vpc_address" "addr_static_bastion" {
  name = var.ipv4_addr_static_bastion_name
  external_ipv4_address {
    zone_id = var.zone
  }
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

  ingress {
    protocol          = "TCP"
    description       = "Allow SSH from Bastion for admin"
    predefined_target = "self_security_group"
    port              = 22
  }

  egress {
    protocol       = "ANY"
    description    = "Allow outgoing traffic to DB and Internet via NAT"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "yandex_vpc_security_group" "db_security_group" {
  name       = var.sg_db_name
  network_id = yandex_vpc_network.my_net.id

  ingress {
    protocol          = "TCP"
    description       = "Allow PG traffic from App"
    security_group_id = yandex_vpc_security_group.app_security_group.id
    port              = 6432
  }

  ingress {
    protocol          = "TCP"
    description       = "Allow Redis traffic from App"
    security_group_id = yandex_vpc_security_group.app_security_group.id
    port              = 6379
  }

  ingress {
    protocol          = "TCP"
    description       = "Allow SSH from Bastion for admin"
    predefined_target = "self_security_group"
    port              = 22
  }

  # Allow Redis mgmt/diagnostics from members of the same SG (e.g., bastion NIC in private-db)
  ingress {
    protocol          = "TCP"
    description       = "Allow Redis traffic from members of DB SG (bastion NIC)"
    predefined_target = "self_security_group"
    port              = 6379
  }

  # Egress is required, otherwise instances in this SG cannot initiate connections (default deny)
  egress {
    protocol       = "ANY"
    description    = "Allow outgoing traffic to Internet via NAT and intra-VPC"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "yandex_vpc_security_group" "bastion_host_group" {
  name       = var.sg_bastion_name
  network_id = yandex_vpc_network.my_net.id
  ingress {
    protocol       = "TCP"
    description    = "Allow incoming traffic"
    port           = 22
    v4_cidr_blocks = var.ip_cidr_allow_ssh_from
  }

  egress {
    protocol       = "ANY"
    description    = "Allow outgoing traffic"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
