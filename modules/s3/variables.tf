variable "bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "force_destroy" {
  type    = bool
  default = false
}
