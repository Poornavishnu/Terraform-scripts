output "sns_topic_arn" {
  value       = aws_sns_topic.config_alerts.arn  #  Replace with your SNS topic resource name
  description = "ARN of the SNS topic for alerts"
}