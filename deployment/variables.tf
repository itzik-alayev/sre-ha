variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "Desired AWS Region to deploy environment on"
}

variable "lambda_image" {
  type        = string
  default     = "006262944085.dkr.ecr.eu-central-1.amazonaws.com/sre-ha-lambda:latest"
  description = "AWS ECR Repository URL to be used for AWS Lambda function"
}
