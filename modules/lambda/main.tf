# 

resource "aws_lambda_function" "terraform_drift_detection" {
  function_name = "terraform-drift-detection"
  role          = var.lambda_role_arn  #  Reference of IAM role from `modules/iam`

  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  memory_size   = 1000
  timeout       = 90

  s3_bucket = var.bucket_name
  s3_key    = var.s3_key

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }

  layers = [
    aws_lambda_layer_version.requests_layer.arn,
    aws_lambda_layer_version.terraform_layer.arn
  ]
}

#  Allow SNS to invoke Lambda

resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_drift_detection.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}

#  Lambda Layer for `requests` library
resource "aws_lambda_layer_version" "requests_layer" {
  layer_name          = "requests-layer"
  description         = "Lambda Layer containing requests module"
  compatible_runtimes = ["python3.9"]
  filename            = "${path.module}/requests-layer.zip"  #  Ensure looks in the local directory
}

#  Lambda Layer for Terraform CLI
resource "aws_lambda_layer_version" "terraform_layer" {
  layer_name          = "terraform-cli-layer"
  s3_bucket          = var.bucket_name
  s3_key             = "lambda-layers/terraform_layer.zip"  # The s3_key defines the location of the ZIP file within the S3 bucket.
  compatible_runtimes = ["python3.9"]
}