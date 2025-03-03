output "control_node_ip" {
  value = module.instance.control_node_ip
}

output "worker_node_ips" {
  value = module.instance.worker_node_ips
}


# IAM 

output "iam_role_name" {
  value = module.iam.iam_role_name
}

output "iam_role_arn" {
  value = module.iam.iam_role_arn
}

output "instance_profile_name" {
  value = module.iam.instance_profile_name
}

output "instance_profile_arn" {
  value = module.iam.instance_profile_arn
}

# network 

output "vpc_id" {
  value = module.network.vpc_id
}

output "subnet_id" {
  value = module.network.subnet_id
}

output "internet_gateway_id" {
  value = module.network.internet_gateway_id
}

output "route_table_id" {
  value = module.network.route_table_id
}


#  AWS config

output "aws_config_recorder" {
  value = module.aws_config.recorder_name
}

output "lambda_arn" {
  value = module.lambda.lambda_arn
}

output "alarm_name" {
  value = module.cloudwatch.alarm_name
}

# s3

output "s3_bucket_name" {
  value = module.s3.bucket_id
}

output "s3_bucket_arn" {
  value = module.s3.bucket_arn
}

# security

output "security_group_id" {
  value = module.security.security_group_id
}




