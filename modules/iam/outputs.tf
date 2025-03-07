output "iam_role_name" {
  description = "Name of the IAM role for EC2"
  value       = aws_iam_role.ec2_role.name
}

output "iam_role_arn" {
  description = "ARN of the IAM role for EC2"
  value       = aws_iam_role.ec2_role.arn
}

output "instance_profile_name" {
  description = "Name of the EC2 IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.name
}

output "instance_profile_arn" {
  description = "ARN of the EC2 IAM instance profile"
  value       = aws_iam_instance_profile.ec2_profile.arn
}

output "lambda_role_arn" {
  description = "ARN of the IAM role for Lambda"
  value       = aws_iam_role.lambda_execution_role.arn
}

output "sns_role_arn" {
  value = aws_iam_role.sns_role.arn
}

output "config_role_arn" {
  description = "ARN of the app_config role for Lambda"
  value       = aws_iam_role.config_role.arn
}

output "ssm_instance_profile_name" {
  description = "IAM instance profile for SSM-managed EC2 instances"
  value       = aws_iam_instance_profile.ssm_instance_profile.name
}