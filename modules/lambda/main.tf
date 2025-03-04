resource "aws_iam_policy" "lambda_policy" {
  name        = "terraform_drift_lambda_policy"
  description = "IAM Policy for Terraform Drift Detection Lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      # Allow Lambda to Write Logs to CloudWatch
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },

      # Allow Lambda to Access Terraform State in S3
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          "arn:aws:s3:::your-terraform-state-bucket",
          "arn:aws:s3:::your-terraform-state-bucket/*"
        ]
      },

      # Allow Lambda to Publish to SNS
      {
        Effect = "Allow",
        Action = "sns:Publish",
        Resource = var.sns_topic_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = var.lambda_role_arn  # ✅ Use IAM role from IAM module
  policy_arn = aws_iam_policy.lambda_policy.arn
}

resource "aws_lambda_function" "terraform_drift_detection" {
  function_name = "terraform-drift-detection"
  role          = var.lambda_role_arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300

  filename         = "${path.module}/lambda_function.zip"  # ✅ Ensure correct path
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")  # ✅ Ensure correct file reference

  environment {
    variables = {
      SNS_TOPIC_ARN = var.sns_topic_arn
    }
  }
}
resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.terraform_drift_detection.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.sns_topic_arn
}