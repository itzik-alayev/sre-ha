data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "sre-ha"
    key    = "infra/terraform.tfstate"
    region = "eu-central-1"
  }
}