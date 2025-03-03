# Enable AWS Config Recorder
resource "aws_config_configuration_recorder" "recorder" {
  name     = "aws-config-recorder"
  role_arn = var.aws_config_role_arn  
}

# AWS Config Delivery Channel (Sends alerts to SNS)
resource "aws_config_delivery_channel" "channel" {
  name           = "aws-config-channel"
  s3_bucket_name = var.bucket_name
  sns_topic_arn  = var.sns_topic_arn  # ✅ Sends alerts to SNS Topic
  depends_on     = [aws_config_configuration_recorder.recorder]
}

# Enable AWS Config Recorder Status
resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
}

# ✅ AWS Config Rules to Detect Changes (Drift Detection)

# Rule 1: Detect if EC2 instances are stopped or terminated
resource "aws_config_config_rule" "ec2_instance_stopped" {
  name = "ec2-instance-stopped"

  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_STOPPED"
  }
}

# Rule 2: Detect if EC2 is unmanaged (not using SSM)
resource "aws_config_config_rule" "ec2_instance_unmanaged" {
  name = "ec2-instance-unmanaged"

  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_MANAGED_BY_SSM"
  }
}

# Rule 3: Detect if an S3 bucket has public read access
resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name = "s3-bucket-public-read-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
}

# Rule 4: Detect IAM Role Changes
resource "aws_config_config_rule" "iam_role_policy_changes" {
  name = "iam-role-policy-changes"

  source {
    owner             = "AWS"
    source_identifier = "IAM_POLICY_IN_USE"
  }
}

