output "omni_s3_backup_endpoint" {
  value = aws_s3_bucket.omni_s3_backup.bucket_regional_domain_name
}

output "omni_s3_backup_id" {

  value = aws_s3_bucket.omni_s3_backup.id
}

output "omni_s3_backup_access_key_id" {
  value = aws_iam_access_key.omni_s3_backup_access_key.id
}

output "omni_s3_backup_access_key_secret" {
  value     = aws_iam_access_key.omni_s3_backup_access_key.secret
  sensitive = true
}