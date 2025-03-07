
#  IAM Role for Lambda Execution (Full Access)

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

# Attach Full AdministratorAccess Policy (Full AWS Access)

# NOT RECOMMENDED - TESTING PURPOSE ONLY !!!!!!!!!!!!!!!!!!!!!

resource "aws_iam_role_policy_attachment" "lambda_admin_access" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


# IAM Role for EC2 (Full Access)

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

# Attach AdministratorAccess to EC2 Role

resource "aws_iam_role_policy_attachment" "ec2_admin_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# EC2 Instance Profile

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_full_access_profile"
  role = aws_iam_role.ec2_role.name
}


# AWS Config Role (Full Access for Compliance)

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

# Attach AWS Managed Policy for AWS Config

resource "aws_iam_role_policy_attachment" "config_role_policy" {
  role       = aws_iam_role.config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}


# IAM Role for SNS (Full Access)

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

# Attach AmazonSNSFullAccess Policy
resource "aws_iam_role_policy_attachment" "sns_full_access_policy" {
  role       = aws_iam_role.sns_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}


# IAM Role for EC2 Systems Manager (SSM)

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

# Attach AmazonSSMManagedInstanceCore Policy

resource "aws_iam_role_policy_attachment" "ssm_role_policy" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# EC2 Instance Profile for SSM

resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "EC2SSMProfile"
  role = aws_iam_role.ssm_role.name
}
