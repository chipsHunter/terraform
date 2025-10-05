
resource "yandex_mdb_postgresql_database" "my_db" {
  cluster_id = yandex_mdb_postgresql_cluster.my_cluster.id
  name       = var.database["ci-db"].name
  owner      = yandex_mdb_postgresql_user.my_user.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
  extension {
    name = "uuid-ossp"
  }
  extension {
    name = "xml2"
  }
}

resource "yandex_mdb_postgresql_user" "my_user" {
  cluster_id = yandex_mdb_postgresql_cluster.my_cluster.id
  name       = var.database_user["java_user"].name
  password   = var.database_user["java_user"].password
}

resource "yandex_mdb_postgresql_cluster" "my_cluster" {
  name        = var.database_cluster["main"].name
  environment = var.database_cluster["main"].environment
  network_id  = yandex_vpc_network.my_net.id

  config {
    version = var.database_cluster["main"].version
    resources {
      resource_preset_id = var.database_cluster["main"].resource_preset_id
      disk_type_id       = var.database_cluster["main"].disk_type_id
      disk_size          = var.database_cluster["main"].disk_size
    }
  }

  host {
    zone      = var.zone
    subnet_id = yandex_vpc_subnet.private_subnets["private-db"].id
  }
}
