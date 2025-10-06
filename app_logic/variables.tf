variable "zone" {
  default = "ru-central1-a"
}

variable "cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "folder_id" {
  description = "Yandex Folder ID"
  type        = string
}
variable "kube_config" {
  description = "Path to k3s config from Java App instance"
  type        = string
}
