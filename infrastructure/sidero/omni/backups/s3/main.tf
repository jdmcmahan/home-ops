resource "aws_s3_bucket" "omni_s3_backup" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_lifecycle_configuration" "omni_s3_backup_lifecycle_rule" {
  bucket = aws_s3_bucket.omni_s3_backup.bucket

  rule {
    id     = "all"
    status = "Enabled"

    filter {}

    expiration {
      days = 30
    }
  }
}

resource "aws_s3_bucket_public_access_block" "omni_s3_backup_access" {
  bucket = aws_s3_bucket.omni_s3_backup.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_user" "omni_s3_backup_user" {
  name = var.omni_iam_user
}

resource "aws_iam_user_policy" "omni_s3_backup_user_policy" {
  name = "omni-s3-backup"
  user = aws_iam_user.omni_s3_backup_user.name

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:ListAllMyBuckets",
          "s3:ListBucket"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.bucket_name}"
        ]
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:DeleteObject",
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.bucket_name}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_access_key" "omni_s3_backup_access_key" {
  user = aws_iam_user.omni_s3_backup_user.name
}
