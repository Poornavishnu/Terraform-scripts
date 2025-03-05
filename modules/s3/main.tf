# ✅ Create S3 Bucket
resource "aws_s3_bucket" "terraform_state_bucket" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true  # ✅ Prevent Terraform from deleting the bucket
    ignore_changes  = [bucket]  # ✅ Ignore modifications to the bucket name
  }
}

# ✅ Enable Versioning for State & Logs
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# ✅ Enable Encryption (AES-256)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ✅ Block Public Access for Security
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.terraform_state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ✅ Define AWS Caller Identity
data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

# ✅ Allow AWS Config to Write Logs to S3
resource "aws_s3_bucket_policy" "terraform_state_bucket_policy" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = [
          "s3:PutObject"
        ],
        Resource = "${aws_s3_bucket.terraform_state_bucket.arn}/AWSLogs/${local.aws_account_id}/Config/*",  # ✅ Correct Prefix
        Condition = {
          StringEquals = {
            "aws:SourceAccount": local.aws_account_id
          }
        }
      },
      {
        Effect = "Allow",
        Principal = {
          Service = "config.amazonaws.com"
        },
        Action = [
          "s3:GetBucketAcl"  # ✅ AWS Config needs this permission
        ],
        Resource = aws_s3_bucket.terraform_state_bucket.arn,
        Condition = {
          StringEquals = {
            "aws:SourceAccount": local.aws_account_id
          }
        }
      }
    ]
  })
}

resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.terraform_state_bucket.id
  key    = "lambda-code/terraform-drift-detection.zip"
  source = "${path.root}/modules/lambda/lambda_function.zip"  # ✅ Correct file location
  etag   = filemd5("${path.root}/modules/lambda/lambda_function.zip")  # ✅ Compute hash from correct path
}