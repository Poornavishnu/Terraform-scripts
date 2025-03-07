terraform {
  backend "s3" {
    bucket         = "terraform-state-vishnu-123456" 
    key            = "terraform.tfstate"
    region         = "us-east-2"
    # dynamodb_table = "terraform-lock" # Optional, for state locking
    encrypt        = true
  }
}