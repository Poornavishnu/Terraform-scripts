output "bucket_id" {
  value = aws_s3_bucket.terraform_state_bucket.id
}

output "bucket_arn" {
  value = aws_s3_bucket.terraform_state_bucket.arn
}

output "s3_bucket_name" {
  value = aws_s3_bucket.terraform_state_bucket.id
}