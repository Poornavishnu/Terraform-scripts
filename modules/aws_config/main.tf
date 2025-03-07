
# AWS Config - 

# AWS config focus on two main things 
# 1. aws config recorder
# 2. aws config rule


# Below is the aws config recorder by default it can record all the resources in the specific region 
# but due to pricing issue I restricted it to record events only related to S3 and EC2
# In this below example we can add multiple resources that we need to track under recording group


resource "aws_config_configuration_recorder" "recorder" {
  name     = "aws-config-recorder"
  role_arn = var.aws_config_role_arn

  recording_group {
    all_supported = false
    resource_types = [
      "AWS::EC2::Instance",
      "AWS::S3::Bucket"  
    ]
  }
}

# The changes tracked by aws config needs to be stores so I am using S3 to store it and I am using SNS to 
# send the alerts to my email

resource "aws_config_delivery_channel" "channel" {
  name           = "aws-config-channel"
  s3_bucket_name = var.bucket_name
  sns_topic_arn  = var.sns_topic_arn

  depends_on = [aws_config_configuration_recorder.recorder]  # Ensures Config Recorder exists first
}

# This resource activates the AWS Config recorder so that it starts capturing configuration changes.
# If the recorder is not active it doesnt record the event changes 


resource "aws_config_configuration_recorder_status" "recorder_status" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true

  depends_on = [aws_config_delivery_channel.channel]  # Ensures the delivery channel exists first
}


# 2. AWS Config Rules to Detect Changes (Drift Detection)
# We can setup these as per our requirement like 
# AWS Config rules evaluate whether AWS resource configurations comply with security best practices or organizational policies.
# Rules can be grouped based on compliance standards (e.g., CIS Benchmark, PCI DSS) or organizational tagging.
# AWS Conformance Packs help organize and deploy multiple rules as a group.
# there are 233 AWS Config managed rules available.




# Detect if EC2 instances have a public IP (instead of stopped instances)
resource "aws_config_config_rule" "ec2_instance_compliance" {
  name = "ec2-instance-compliance"

  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_NO_PUBLIC_IP"  # Valid AWS rule
  }
}

# Detect if EC2 is NOT using Systems Manager (SSM)
resource "aws_config_config_rule" "ec2_instance_unmanaged" {
  name = "ec2-instance-unmanaged"

  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_MANAGED_BY_SSM"
  }
}

# Detect if an S3 bucket has public read access
resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name = "s3-bucket-public-read-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }
}

# Detect if an ec2 is stopped 
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