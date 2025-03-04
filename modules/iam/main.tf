# EC2 ROLE AND EC2 PROFILE 

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
    ignore_changes = [name]  # ✅ Prevent Terraform from modifying/deleting it
  }
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.cluster_name}-profile"
  role = aws_iam_role.ec2_role.name

  lifecycle {
    prevent_destroy = true  # ✅ Prevent accidental deletion
    ignore_changes  = [name]  # ✅ Ignore instance profile name changes
  }
}

#  AWS CONFIG ROLE 


resource "aws_iam_role" "config_role" {
  name = "aws_config_role"
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
    Version = "2012-10-17"
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

# ✅ Attach the PassRole Policy to aws_config_role
resource "aws_iam_role_policy_attachment" "aws_config_passrole_attachment" {
  policy_arn = aws_iam_policy.aws_config_passrole_policy.arn
  role       = aws_iam_role.config_role.name
}
# Attach AWS Managed Config Role Policy
resource "aws_iam_role_policy_attachment" "config_role_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}


# AWS LAMBDA ROLE AND POLICY ATTACHMENT

resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda_basic_execution"
  roles      = [aws_iam_role.lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


#  SNS ROLE AND POLICY FOR NOTIFICATIONS

resource "aws_iam_role" "sns_role" {
  name = "sns_publish_role"

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