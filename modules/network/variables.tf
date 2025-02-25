variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for subnet"
  type        = string
}

variable "region" {
  description = "AWS Region"
  type        = string
}

variable "cluster_name" {
  description = "Prefix for naming network resources"
  type        = string
}