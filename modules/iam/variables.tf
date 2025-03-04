variable "cluster_name" {
  description = "Name prefix for IAM resources"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS Topic ARN for Lambda notifications"
  type        = string
}
