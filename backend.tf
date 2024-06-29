terraform {
  backend "s3" {
    bucket = "s3-to-rds-tf-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}