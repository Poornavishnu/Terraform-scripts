output "recorder_name" {
  value = aws_config_configuration_recorder.recorder.name
}

output "config_role_arn" {
  value = var.aws_config_role_arn
}