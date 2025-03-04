# Enable AWS Config Recorder
# resource "aws_config_configuration_recorder" "recorder" {
#   name     = "aws-config-recorder"
#   role_arn = var.aws_config_role_arn  

#   recording_group {
#   all_supported = false
#   include_global_resource_types = false  # Disable global tracking (IAM, CloudTrail, etc.)
#   resource_types = [
#     "AWS::EC2::Instance"  # ✅ Only track EC2
#   ]
# }
# }

# AWS Config Configuration Recorder (Tracks Only EC2)
# resource "aws_config_configuration_recorder" "recorder" {
#   name     = "aws-config-recorder"
#   role_arn = var.aws_config_role_arn

#   recording_group {
#     all_supported = false
#     resource_types = [
#       "AWS::EC2::Instance",
#       "AWS::S3::Bucket"  # ✅ Add S3 as an additional resource to test
#     ]
#   }
# }

# resource "aws_config_configuration_recorder" "recorder" {
#   name     = "aws-config-recorder"
#   role_arn = var.aws_config_role_arn # Ensure correct IAM role

#   recording_group {
#     all_supported = false
#     resource_types = [
#       "AWS::EC2::Instance"  # ✅ Matches the CLI command that worked
#     ]
#   }
# }

resource "aws_config_configuration_recorder" "recorder" {
  name     = "aws-config-recorder"
  role_arn = var.aws_config_role_arn  # Ensure this IAM role exists

  recording_group {
    all_supported                 = false
    include_global_resource_types = false  # ✅ Ensures IAM resources aren't required
    resource_types                = ["AWS::EC2::Instance"]  # ✅ AWS requires a valid resource type
  }
}

# ✅ AWS Config Delivery Channel (Logs to S3, Sends Alerts to SNS)
resource "aws_config_delivery_channel" "channel" {
  name           = "aws-config-channel"
  s3_bucket_name = var.bucket_name
  sns_topic_arn  = var.sns_topic_arn

  depends_on = [aws_config_configuration_recorder.recorder]  # ✅ Ensure the recorder exists first
}

# ✅ Enable AWS Config Recorder Status
resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.channel]  # ✅ Ensure the delivery channel exists first
}

# ✅ AWS Config Rules to Detect Changes (Drift Detection)

# Rule 1: Detect if EC2 instances have a public IP (instead of stopped instances)
resource "aws_config_config_rule" "ec2_instance_compliance" {
  name = "ec2-instance-compliance"

  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_NO_PUBLIC_IP"  # ✅ Valid AWS rule
  }
}

# Rule 2: Detect if EC2 is NOT using Systems Manager (SSM)
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

# Rule 4: Detect IAM Role Changes (Ensure `policyARN` is a LIST)
resource "aws_config_config_rule" "iam_role_policy_changes" {
  name = "iam-role-policy-changes"

  source {
    owner             = "AWS"
    source_identifier = "IAM_POLICY_IN_USE"
  }

  input_parameters = jsonencode({
    policyARN = "arn:aws:iam::aws:policy/AdministratorAccess"  # ✅ Ensure this is NOT blank
  })
}

resource "aws_config_config_rule" "ec2_stopped_instance" {
  name = "ec2-stopped-instance"

  source {
    owner             = "AWS"
    source_identifier = "EC2_STOPPED_INSTANCE"
  }

  scope {
    compliance_resource_types = ["AWS::EC2::Instance"]
  }

  maximum_execution_frequency = "TwentyFour_Hours"
}