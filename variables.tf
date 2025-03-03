variable "region" {
  description = "AWS region for deployment"
  default     = "us-east-2"
}

variable "cluster_name" {
  description = "Prefix used to name all cluster resources"
  default     = "my-cluster"
}

variable "ami" {
  description = "AMI for EC2 instances"
  default     = "ami-088b41ffb0933423f"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "AWS EC2 key pair name"
  default     = "cka"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "Subnet CIDR block"
  default     = "10.0.1.0/24"
}

variable "bucket_name" {
  description = "S3 bucket name for Terraform state"
  default     = "terraform-state-vishnu-123456"
}


# AWS CONFIG


