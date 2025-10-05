
resource "yandex_compute_instance" "redis" {
  name        = var.instance_redis["main"].name
  platform_id = var.instance_redis["main"].platform_id
  zone        = var.zone

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    device_name = var.instance_redis["main"].disk_params.name
    initialize_params {
      size     = var.instance_redis["main"].disk_params.size
      type     = var.instance_redis["main"].disk_params.type
      image_id = data.yandex_compute_image.container_optimized_image.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnets["private-db"].id
    security_group_ids = [yandex_vpc_security_group.db_security_group.id]
  }

  metadata = {
    docker-compose = file("${path.module}/${var.script_dir}/docker-compose.yaml")
    user-data = templatefile("${path.module}/${var.script_dir}/cloud_config.yaml.tftpl", {
      ssh_key = file(var.instance_redis["main"].ssh_key_file_path)
    })
  }
}


resource "yandex_compute_instance" "bastion" {
  name        = var.instance_bastion["main"].name
  platform_id = var.instance_bastion["main"].platform_id
  zone        = var.zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    device_name = var.instance_bastion["main"].disk_params.name
    initialize_params {
      size     = var.instance_bastion["main"].disk_params.size
      type     = var.instance_bastion["main"].disk_params.type
      image_id = data.yandex_compute_image.latest_ubuntu.id
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public_subnet.id
    nat_ip_address     = yandex_vpc_address.addr_static_bastion.external_ipv4_address[0].address
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion_host_group.id]
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnets["private-app"].id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.app_security_group.id]
  }
  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnets["private-db"].id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.db_security_group.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.instance_bastion["main"].ssh_key_file_path)}"
  }
}
