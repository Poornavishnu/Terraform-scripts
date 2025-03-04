provider "aws" {
  region = var.region
}

module "network" {
  source       = "./modules/network"
  region       = var.region
  vpc_cidr     = var.vpc_cidr
  subnet_cidr  = var.subnet_cidr
  cluster_name = var.cluster_name
}

module "security" {
  source       = "./modules/security"
  vpc_id       = module.network.vpc_id
  vpc_cidr     = var.vpc_cidr
  cluster_name = var.cluster_name
}

module "iam" {
  source       = "./modules/iam"
  cluster_name = var.cluster_name
  sns_topic_arn = module.sns.sns_topic_arn  # ✅ Pass SNS ARN dynamically
}

module "instance" {
  source                = "./modules/instance"
  ami                   = var.ami
  instance_type         = var.instance_type
  subnet_id             = module.network.subnet_id
  key_name              = var.key_name
  vpc_security_group_id = module.security.security_group_id
  iam_instance_profile  = module.iam.ssm_instance_profile_name  
  cluster_name          = var.cluster_name
}
data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}
module "s3" {
  source        = "./modules/s3"
  bucket_name   = var.bucket_name
  force_destroy = true
}


#  AWS CONFIG 

module "aws_config" {
  source              = "./modules/aws_config"
  aws_config_role_arn = module.iam.config_role_arn
  bucket_name         = var.bucket_name
  sns_topic_arn       = module.sns.sns_topic_arn
  depends_on          = [module.s3]  # Ensure S3 (including its policy) is applied first
}

module "lambda" {
  source         = "./modules/lambda"
  lambda_role_arn = module.iam.lambda_role_arn  # ✅ Pass IAM role from IAM module
  sns_topic_arn  = module.sns.sns_topic_arn
}

module "cloudwatch" {
  source         = "./modules/cloudwatch"
  sns_topic_arn = module.sns.sns_topic_arn
}

module "sns" {
  source = "./modules/sns"
  sns_topic_arn  = module.sns.sns_topic_arn
}