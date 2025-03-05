variable "cluster_name" {
  description = "Name prefix for IAM resources"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS Topic ARN for Lambda notifications"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM Role ARN for Lambda function"
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "s3_key" {
  description = "The S3 key (object path) for the Lambda function ZIP file"
  type        = string
}