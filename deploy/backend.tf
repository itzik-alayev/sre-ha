terraform {
  backend "s3" {
    region  = "eu-central-1"
    bucket  = "sre-ha"
    key     = "deploy/terraform.tfstate"
    encrypt = true
  }
}