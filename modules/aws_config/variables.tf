variable "bucket_name" {
  description = "Existing S3 bucket for AWS Config logs"
  type        = string
}

variable "aws_config_role_arn" {
  description = "IAM Role ARN for AWS Config"
  type        = string
}