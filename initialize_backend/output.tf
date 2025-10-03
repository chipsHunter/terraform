output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = yandex_storage_bucket.iam-bucket.bucket
}

/*

no permissions...

output "ydb_table_name" {
  description = "Name of the YDB table for state locking"
  value       = yandex_ydb_database_serverless.managed_ydb.name
}

output "ydb_endpoint" {
  description = "Document API endpoint for the YDB table"
  value       = yandex_ydb_database_serverless.managed_ydb.document_api_endpoint
}
*/
