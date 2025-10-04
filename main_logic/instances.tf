
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
      image_id = data.yandex_compute_image.latest_ubuntu.id
    }
  }

  network_interface {
    index              = 1
    subnet_id          = yandex_vpc_subnet.private_subnets["private-db"].id
    security_group_ids = [yandex_vpc_security_group.app_security_group.id]
  }

  metadata = {
    user-data = file("${path.module}/scripts/initialize_redis.sh")
    ssh-keys  = "ubuntu:${file(var.instance_redis["main"].ssh_key_file_path)}"
  }
}
