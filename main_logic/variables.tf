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
variable "service_account_key_file" {
  description = "Terraform Service Account Key Path"
  type        = string
}

variable "s3_folder_name" {
  description = "Prefix for tfstate in S3 bucket"
  type        = string
}
