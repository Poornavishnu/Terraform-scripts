resource "aws_cloudwatch_log_group" "lambda_logs" {
  name = "/aws/lambda/compliance_checker"
}

resource "aws_cloudwatch_metric_alarm" "non_compliant_alarm" {
  alarm_name          = "NonCompliantResources"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "NonCompliantResources"
  namespace          = "AWS/Config"
  period             = 60
  statistic         = "Sum"
  threshold         = 1
  alarm_description = "Triggers when non-compliant resources are detected"
  actions_enabled   = true
  alarm_actions     = [var.sns_topic_arn]
}