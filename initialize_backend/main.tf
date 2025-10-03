terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}
provider "yandex" {
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  service_account_key_file = var.service_account_key_file
  zone                     = var.zone
}


resource "yandex_kms_symmetric_key" "key-a" {
  name              = var.s3_key["name"]
  default_algorithm = var.s3_key["algorithm"]
  rotation_period   = var.s3_key["rotation_period"]
}
resource "yandex_storage_bucket" "iam-bucket" {
  bucket = var.bucket_name

  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.key-a.id
        sse_algorithm     = "aws:kms"
      }
    }
  }
  lifecycle_rule {
    id      = "cleanupoldversions"
    enabled = true

    filter {
      prefix = var.bucket_data_folder
    }

    noncurrent_version_transition {
      days          = 30
      storage_class = "COLD"
    }

    noncurrent_version_expiration {
      days = 90
    }
  }
}

