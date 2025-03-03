resource "aws_lambda_permission" "allow_config" {
  statement_id  = "AllowExecutionFromAWSConfig"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name  # ✅ Correct Lambda function reference
  principal     = "config.amazonaws.com"
}

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}

resource "aws_lambda_function" "my_lambda" {
  function_name    = "my_lambda_function"
  role             = var.lambda_role_arn
  handler          = "lambda_function.lambda_handler"  # Make sure this matches your function in Python
  runtime          = "python3.8"
  filename         = "${path.module}/lambda_function.zip"  # Use ZIP file
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")
}