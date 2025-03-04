output "lambda_arn" {
  value = aws_lambda_function.terraform_drift_detection.arn
  description = "Lambda function ARN"
}