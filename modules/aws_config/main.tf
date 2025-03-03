resource "aws_config_configuration_recorder" "recorder" {
  name     = "aws-config-recorder"
  role_arn = var.aws_config_role_arn  
}

resource "aws_config_delivery_channel" "channel" {
  name           = "aws-config-channel"
  s3_bucket_name = var.bucket_name
  depends_on     = [aws_config_configuration_recorder.recorder]
}

resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
}
