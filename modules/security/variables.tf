variable "vpc_id" {
  description = "The VPC ID where security group will be created"
  type        = string
}

variable "cluster_name" {
  description = "Prefix for naming security group"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block of VPC for internal communication"
  type        = string
}