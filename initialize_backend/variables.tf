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

variable "bucket_name" {
  description = "Name of S3 bucket containing backend"
  type        = string
}
variable "bucket_data_folder" {
  description = "Folder where this .tfstate file should be placed"
  type        = string
}
variable "s3_key" {
  description = "Key for symmetric crypting"
  type        = map(string)
}

variable "ydb_name" {
  description = "Name for Managed YDB"
  type        = string
}

