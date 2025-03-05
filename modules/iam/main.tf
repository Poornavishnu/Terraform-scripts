# # ============================================
# # ✅ IAM Policy for Terraform Drift Detection Lambda
# # ============================================
# resource "aws_iam_policy" "terraform_drift_lambda_policy" {
#   name        = "terraform_drift_lambda_policy"
#   description = "IAM Policy for Terraform Drift Detection Lambda"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [

#       # ✅ Allow Lambda to Write Logs to CloudWatch
#       {
#         Effect = "Allow",
#         Action = [
#           "logs:CreateLogGroup",
#           "logs:CreateLogStream",
#           "logs:PutLogEvents",
#           "logs:DescribeLogGroups",
#           "logs:ListTagsForResource"
#         ],
#         Resource = "arn:aws:logs:*:*:*"
#       },

#       # ✅ Allow Lambda to Access Terraform State in S3
#       {
#         Effect = "Allow",
#         Action = [
#           "s3:GetObject",
#           "s3:ListBucket"
#         ],
#         Resource = [
#           "arn:aws:s3:::${var.bucket_name}",
#           "arn:aws:s3:::${var.bucket_name}/*"
#         ]
#       },

#       # ✅ Allow Lambda to Publish to SNS
#       {
#         Effect = "Allow",
#         Action = [
#           "sns:Publish",
#           "sns:GetTopicAttributes"
#         ],
#         Resource = var.sns_topic_arn
#       },

#       # ✅ AWS CONFIG SERVICE PERMISSIONS (For Drift Detection)
#       {
#         Effect = "Allow",
#         Action = [
#           "config:DescribeConfigurationRecorders",
#           "config:DescribeConfigurationRecorderStatus",
#           "config:DescribeDeliveryChannels",
#           "config:DescribeConfigRules",
#           "config:GetComplianceDetailsByConfigRule",
#           "config:GetComplianceSummaryByConfigRule",
#           "config:ListTagsForResource"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# # ============================================
# # ✅ IAM Role for Lambda Execution
# # ============================================
# resource "aws_iam_role" "lambda_execution_role" {
#   name = "lambda_execution_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Principal = { Service = "lambda.amazonaws.com" },
#       Action = "sts:AssumeRole"
#     }]
#   })
# }

# # ============================================
# # ✅ Attach the Terraform Drift Detection Policy to Lambda Role
# # ============================================
# resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
#   role       = aws_iam_role.lambda_execution_role.name
#   policy_arn = aws_iam_policy.terraform_drift_lambda_policy.arn
# }

# # ============================================
# # ✅ Attach AWS Managed Policy for Basic Lambda Execution
# # ============================================
# resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
#   role       = aws_iam_role.lambda_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
# }

# # ============================================
# # ✅ IAM Policy for Terraform Execution in Lambda
# # ============================================
# # resource "aws_iam_policy" "terraform_execution_policy" {
# #   name        = "terraform_execution_policy"
# #   description = "Policy allowing Terraform execution inside Lambda"

# #   policy = jsonencode({
# #     Version = "2012-10-17",
# #     Statement = [
# #       {
# #         Effect   = "Allow"
# #         Action   = [
# #           "s3:*",
# #           "ec2:*",
# #           "iam:*",
# #           "lambda:*",
# #           "cloudwatch:*",
# #           "dynamodb:*"
# #         ]
# #         Resource = "*"
# #       }
# #     ]
# #   })
# # }

# resource "aws_iam_policy" "terraform_execution_policy" {
#   name        = "terraform_execution_policy"
#   description = "Policy allowing Terraform execution inside Lambda"
  
#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [

#       # ✅ CloudWatch Logs
#       {
#         Effect   = "Allow",
#         Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents", "logs:ListTagsForResource"],
#         Resource = "arn:aws:logs:*:*:*"
#       },

#       # ✅ S3 (Terraform State)
#       {
#         Effect   = "Allow",
#         Action   = ["s3:GetObject", "s3:ListBucket"],
#         Resource = ["arn:aws:s3:::your-terraform-state-bucket", "arn:aws:s3:::your-terraform-state-bucket/*"]
#       },

#       # ✅ SNS (For Notifications)
#       {
#         Effect   = "Allow",
#         Action   = ["sns:Publish", "sns:ListTagsForResource"],
#         Resource = "arn:aws:sns:us-east-2:970547371216:config-alerts-topic"
#       },

#       # ✅ AWS Config (For Drift Detection)
#       {
#         Effect   = "Allow",
#         Action   = [
#           "config:DescribeConfigurationRecorders",
#           "config:DescribeConfigurationRecorderStatus",
#           "config:DescribeDeliveryChannels",
#           "config:DescribeConfigRules",
#           "config:GetComplianceDetailsByConfigRule",
#           "config:GetComplianceSummaryByConfigRule",
#           "config:ListTagsForResource"
#         ],
#         Resource = "*"
#       },

#       # ✅ EC2, IAM, Lambda (if needed)
#       {
#         Effect   = "Allow",
#         Action   = ["ec2:*", "iam:*", "lambda:*"],
#         Resource = "*"
#       }
#     ]
#   })
# }

# # ============================================
# # ✅ Attach Terraform Execution Policy to Lambda Role
# # ============================================
# resource "aws_iam_role_policy_attachment" "terraform_execution_attachment" {
#   role       = aws_iam_role.lambda_execution_role.name
#   policy_arn = aws_iam_policy.terraform_execution_policy.arn
# }

# # ============================================
# # ✅ AWS Config Role
# # ============================================
# resource "aws_iam_role" "config_role" {
#   name = "aws-config-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = "sts:AssumeRole",
#       Effect = "Allow",
#       Principal = { Service = "config.amazonaws.com" }
#     }]
#   })
# }

# resource "aws_iam_policy" "aws_config_passrole_policy" {
#   name        = "AWSConfigPassRolePolicy"
#   description = "Allow AWS Config to assume aws_config_role"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect   = "Allow",
#       Action   = "iam:PassRole",
#       Resource = aws_iam_role.config_role.arn,
#       Condition = { StringEquals = { "iam:PassedToService": "config.amazonaws.com" } }
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "aws_config_passrole_attachment" {
#   role       = aws_iam_role.config_role.name
#   policy_arn = aws_iam_policy.aws_config_passrole_policy.arn
# }

# resource "aws_iam_role_policy_attachment" "config_role_policy" {
#   role       = aws_iam_role.config_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
# }

# # ============================================
# # ✅ EC2 Role and Profile
# # ============================================
# resource "aws_iam_role" "ec2_role" {
#   name = "my-cluster-ec2-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Principal = { Service = "ec2.amazonaws.com" },
#       Action = "sts:AssumeRole"
#     }]
#   })
# }

# resource "aws_iam_instance_profile" "ec2_profile" {
#   name = "${var.cluster_name}-profile"
#   role = aws_iam_role.ec2_role.name
# }

# # ============================================
# # ✅ EC2 SSM Role
# # ============================================
# resource "aws_iam_role" "ssm_role" {
#   name = "EC2SSMRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Principal = { Service = "ec2.amazonaws.com" },
#       Action = "sts:AssumeRole"
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ssm_role_policy" {
#   role       = aws_iam_role.ssm_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }

# resource "aws_iam_instance_profile" "ssm_instance_profile" {
#   name = "EC2SSMProfile"
#   role = aws_iam_role.ssm_role.name
# }

# # ============================================
# # ✅ SNS Role and Policy for Notifications
# # ============================================
# resource "aws_iam_role" "sns_role" {
#   name = "sns-publish-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Action = "sts:AssumeRole",
#       Effect = "Allow",
#       Principal = { Service = "sns.amazonaws.com" }
#     }]
#   })
# }

# resource "aws_iam_role_policy_attachment" "sns_publish_policy" {
#   role       = aws_iam_role.sns_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
# }
# resource "aws_iam_role" "lambda_role" {
#   name = "lambda_execution_role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [{
#       Effect = "Allow",
#       Principal = { Service = "lambda.amazonaws.com" },
#       Action = "sts:AssumeRole"
#     }]
#   })
# }

# ============================================
# ✅ IAM Role for Lambda Execution (Full Access)
# ============================================
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# ✅ Attach Full AdministratorAccess Policy (Full AWS Access)
resource "aws_iam_role_policy_attachment" "lambda_admin_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ============================================
# ✅ IAM Role for EC2 (Full Access)
# ============================================
resource "aws_iam_role" "ec2_role" {
  name = "ec2_full_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# ✅ Attach AdministratorAccess to EC2 Role
resource "aws_iam_role_policy_attachment" "ec2_admin_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ✅ EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_full_access_profile"
  role = aws_iam_role.ec2_role.name
}

# ============================================
# ✅ AWS Config Role (Full Access for Compliance)
# ============================================
resource "aws_iam_role" "config_role" {
  name = "aws-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "config.amazonaws.com" }
    }]
  })
}

# ✅ Attach AWS Managed Policy for AWS Config
resource "aws_iam_role_policy_attachment" "config_role_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

# ============================================
# ✅ IAM Role for SNS (Full Access)
# ============================================
resource "aws_iam_role" "sns_role" {
  name = "sns_full_access_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = { Service = "sns.amazonaws.com" }
    }]
  })
}

# ✅ Attach AmazonSNSFullAccess Policy
resource "aws_iam_role_policy_attachment" "sns_full_access_policy" {
  role       = aws_iam_role.sns_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

# ============================================
# ✅ IAM Role for EC2 Systems Manager (SSM)
# ============================================
resource "aws_iam_role" "ssm_role" {
  name = "EC2SSMRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# ✅ Attach AmazonSSMManagedInstanceCore Policy
resource "aws_iam_role_policy_attachment" "ssm_role_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ✅ EC2 Instance Profile for SSM
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "EC2SSMProfile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}