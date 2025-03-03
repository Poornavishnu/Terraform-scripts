resource "aws_lambda_function" "my_lambda" {
  function_name = "my_lambda_function"
  role          = var.lambda_role_arn  # Dynamically use IAM role from IAM module
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")
}

resource "aws_lambda_permission" "allow_config" {
  statement_id  = "AllowExecutionFromAWSConfig"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name  # ✅ Correct Lambda function reference
  principal     = "config.amazonaws.com"
}
