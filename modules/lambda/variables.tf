variable "sns_topic_arn" {
  description = "SNS Topic ARN for notifications"
  type        = string
}
variable "lambda_role_arn" {
  description = "IAM Role ARN for Lambda function"
  type        = string
}