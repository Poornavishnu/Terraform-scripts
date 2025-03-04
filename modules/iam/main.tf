# ✅ EC2 Role and Profile
resource "aws_iam_role" "ec2_role" {
  name = "my-cluster-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })

  lifecycle {
    prevent_destroy = true
    ignore_changes = [name]  # Prevent Terraform from modifying/deleting it
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.cluster_name}-profile"
  role = aws_iam_role.ec2_role.name

  lifecycle {
    prevent_destroy = true  # Prevent accidental deletion
    ignore_changes  = [name]  # Ignore instance profile name changes
  }
}

# ✅ AWS Config Role
resource "aws_iam_role" "config_role" {
  name = "aws-config-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "config.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy" "aws_config_passrole_policy" {
  name        = "AWSConfigPassRolePolicy"
  description = "Allow AWS Config to assume aws_config_role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = aws_iam_role.config_role.arn
        Condition = {
          StringEquals = {
            "iam:PassedToService": "config.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_config_passrole_attachment" {
  policy_arn = aws_iam_policy.aws_config_passrole_policy.arn
  role       = aws_iam_role.config_role.name
}

resource "aws_iam_role_policy_attachment" "config_role_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# ✅ Check if the Lambda Policy already exists
data "aws_iam_policy" "existing_lambda_policy" {
  name = "terraform_drift_lambda_policy"
}

# ✅ Create the policy only if it does NOT already exist
resource "aws_iam_policy" "lambda_policy" {
  count = length(data.aws_iam_policy.existing_lambda_policy.arn) > 0 ? 0 : 1
  name        = "terraform_drift_lambda_policy"
  description = "IAM Policy for Terraform Drift Detection Lambda"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [

      # ✅ Allow Lambda to Write Logs to CloudWatch
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },

      # ✅ Allow Lambda to Access Terraform State in S3
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

      # ✅ Allow Lambda to Publish to SNS (For Drift Alerts)
      {
        Effect = "Allow",
        Action = "sns:Publish",
        Resource = var.sns_topic_arn
      }
    ]
  })
}

# ✅ Lambda Role
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# ✅ Attach the correct policy (either existing or newly created)
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = coalesce(
    one(aws_iam_policy.lambda_policy[*].arn),  # ✅ Use the new policy ARN if created
    data.aws_iam_policy.existing_lambda_policy.arn  # ✅ Use the existing policy if it already exists
  )
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ✅ SNS Role and Policy for Notifications
resource "aws_iam_role" "sns_role" {
  name = "sns-publish-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "sns.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "sns_publish_policy" {
  name       = "sns_publish_policy"
  roles      = [aws_iam_role.sns_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

# ✅ EC2 SSM Role
resource "aws_iam_role" "ssm_role" {
  name = "EC2SSMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_role_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "EC2SSMProfile"
  role = aws_iam_role.ssm_role.name
}