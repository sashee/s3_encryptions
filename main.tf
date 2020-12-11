provider "aws" {
}

data "aws_caller_identity" "current" {}

# S3 bucket

resource "aws_s3_bucket" "bucket" {
  force_destroy = "true"
}

resource "aws_s3_bucket_object" "no_encryption" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "no_encryption.txt"
  content = "No encryption"
}

resource "aws_s3_bucket_object" "sse-s3" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "sse-s3.txt"
  content = "SSE-S3"
  server_side_encryption = "AES256"
}

resource "aws_s3_bucket_object" "sse-kms-default" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "sse-kms-default.txt"
  content = "SSE-KMS with default CMK"
  server_side_encryption = "aws:kms"
}

resource "aws_s3_bucket_object" "sse-kms-customer-managed" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "sse-kms-customer-managed.txt"
  content = "SSE-KMS with customer-managed CMK"
  kms_key_id = aws_kms_key.custom_key.arn

}

resource "aws_kms_key" "custom_key" {
  deletion_window_in_days = 7
}

data "aws_iam_policy_document" "access_bucket" {
  statement {
    actions = [
      "s3:PutObject",
    ]
    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }
  statement {
    actions = [
      "s3:GetObject",
    ]
    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }
}

resource "aws_iam_policy" "access_bucket" {
  policy = data.aws_iam_policy_document.access_bucket.json
}

data "aws_iam_policy_document" "access_key" {
  statement {
    # custom CMK
    # https://aws.amazon.com/premiumsupport/knowledge-center/s3-large-file-encryption-kms-key/
    # https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingKMSEncryption.html
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey",
    ]
    resources = [
      aws_kms_key.custom_key.arn,
    ]
  }
}

resource "aws_iam_policy" "access_key" {
  policy = data.aws_iam_policy_document.access_key.json
}

data "aws_iam_policy_document" "trust_current_account" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_iam_role" "access-bucket-role" {
  assume_role_policy = data.aws_iam_policy_document.trust_current_account.json
}

resource "aws_iam_role_policy_attachment" "access-bucket-1" {
  role       = aws_iam_role.access-bucket-role.name
  policy_arn = aws_iam_policy.access_bucket.arn
}

resource "aws_iam_role" "access-key-role" {
  assume_role_policy = data.aws_iam_policy_document.trust_current_account.json
}

resource "aws_iam_role_policy_attachment" "access-key-1" {
  role       = aws_iam_role.access-key-role.name
  policy_arn = aws_iam_policy.access_bucket.arn
}
resource "aws_iam_role_policy_attachment" "access-key-2" {
  role       = aws_iam_role.access-key-role.name
  policy_arn = aws_iam_policy.access_key.arn
}

output "access-bucket-role" {
  value = aws_iam_role.access-bucket-role.arn
}

output "access-key-role" {
  value = aws_iam_role.access-key-role.arn
}

output "bucket" {
	value = aws_s3_bucket.bucket.bucket
}

output "no_encryption" {
	value = aws_s3_bucket_object.no_encryption.key
}

output "sse-s3" {
	value = aws_s3_bucket_object.sse-s3.key
}

output "sse-kms-default" {
	value = aws_s3_bucket_object.sse-kms-default.key
}
output "sse-kms-customer-managed" {
	value = aws_s3_bucket_object.sse-kms-customer-managed.key
}
