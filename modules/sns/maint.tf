resource "aws_sns_topic" "config_alerts" {
  name = "config-alerts-topic"
}

resource "aws_sns_topic_policy" "sns_policy" {
  arn = aws_sns_topic.config_alerts.arn
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = "*",
      Action = "SNS:Publish",
      Resource = aws_sns_topic.config_alerts.arn
    }]
  })
}