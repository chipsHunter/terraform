data "yandex_compute_image" "latest_ubuntu" {
  family = "ubuntu-2204-lts"
}

output "ubuntu_image" {
  value = data.yandex_compute_image.latest_ubuntu.description
}
