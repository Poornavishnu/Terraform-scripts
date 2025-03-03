variable "bucket_name" {
  description = "Existing S3 bucket for AWS Config logs"
  type        = string
}

variable "aws_config_role_arn" {
  description = "IAM Role ARN for AWS Config"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS Topic ARN for AWS Config notifications"
  type        = string
}