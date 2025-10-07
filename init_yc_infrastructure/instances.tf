
resource "yandex_compute_instance" "redis" {
  name        = local.redis_inst_name
  platform_id = var.instance_params["redis"].platform_id
  zone        = var.zone

  resources {
    cores  = var.instance_params["redis"].cores
    memory = var.instance_params["redis"].memory
  }

  boot_disk {
    device_name = var.instance_params["redis"].disk_params.name
    initialize_params {
      size     = var.instance_params["redis"].disk_params.size
      type     = var.instance_params["redis"].disk_params.type
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
      ssh_key = file(var.instance_params["redis"].ssh_key_file_path)
    })
  }
}


resource "yandex_compute_instance" "app" {
  name        = local.app_inst_name
  platform_id = var.instance_params["app"].platform_id
  zone        = var.zone

  resources {
    cores  = var.instance_params["app"].cores
    memory = var.instance_params["app"].memory
  }

  boot_disk {
    device_name = var.instance_params["app"].disk_params.name
    initialize_params {
      size     = var.instance_params["app"].disk_params.size
      type     = var.instance_params["app"].disk_params.type
      image_id = data.yandex_compute_image.container_optimized_image.id
    }
  }

  service_account_id = var.main_terraform_sa_id

  network_interface {
    subnet_id          = yandex_vpc_subnet.private_subnets["private-app"].id
    security_group_ids = [yandex_vpc_security_group.app_security_group.id]
  }

  metadata = {
    ssh-keys  = "ubuntu:${file(var.instance_params["bastion"].ssh_key_file_path)}"
    user-data = file("${path.module}/${var.script_dir}/init_app_inst.sh")
  }
}

resource "yandex_compute_instance" "bastion" {
  name        = local.bastion_inst_name
  platform_id = var.instance_params["bastion"].platform_id
  zone        = var.zone

  resources {
    cores  = var.instance_params["bastion"].cores
    memory = var.instance_params["bastion"].memory
  }

  boot_disk {
    device_name = var.instance_params["bastion"].disk_params.name
    initialize_params {
      size     = var.instance_params["bastion"].disk_params.size
      type     = var.instance_params["bastion"].disk_params.type
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
    ssh-keys  = "ubuntu:${file(var.instance_params["bastion"].ssh_key_file_path)}"
    user-data = file("${path.module}/${var.script_dir}/init_ipv4_forwarding.sh")
  }
}
