variable "lambda_role_arn" {
  description = "IAM Role ARN for Lambda function"
  type        = string
}
variable "sns_topic_arn" {
  description = "SNS Topic ARN for Lambda notifications"
  type        = string
}