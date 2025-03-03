terraform {
  backend "s3" {
    bucket         = "terraform-state-vishnu-123456" # Replace with your actual S3 bucket name
    key            = "terraform.tfstate"
    region         = "us-east-2"
    # dynamodb_table = "terraform-lock" # Optional, for state locking
    encrypt        = true
  }
}