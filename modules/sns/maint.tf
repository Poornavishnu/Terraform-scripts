# Create SNS Topic
resource "aws_sns_topic" "config_alerts" {
  name = "config-alerts-topic"
}

# Attach SNS Topic Policy
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

# # SNS Subscription for Lambda
# resource "aws_sns_topic_subscription" "lambda_subscription" {
#   topic_arn = aws_sns_topic.config_alerts.arn
#   protocol  = "lambda"
#   endpoint  = module.lambda.lambda_function_arn  # Ensure this references your Lambda ARN
# }

# SNS Subscription for Email
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.config_alerts.arn
  protocol  = "email"
  endpoint  = "gattupoornavishnu941@gmail.com"
}

# SNS Subscription for Mobile (SMS)
resource "aws_sns_topic_subscription" "sms_subscription" {
  topic_arn = aws_sns_topic.config_alerts.arn
  protocol  = "sms"
  endpoint  = "+14168368940"  
}