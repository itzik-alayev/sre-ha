data "terraform_remote_state" "infra" {
  backend = "s3"
  config = {
    bucket = "sre-ha"
    key    = "infra/terraform.tfstate"
    region = "eu-central-1"
  }
}

locals {
  api_gateway_id            = data.terraform_remote_state.infra.outputs.api_gateway_id
  api_gateway_execution_arn = data.terraform_remote_state.infra.outputs.api_gateway_execution_arn
  cluster_name              = data.terraform_remote_state.infra.outputs.cluster_name
  lambda_role_arn           = data.terraform_remote_state.infra.outputs.lambda_role_arn
  ecr_repository_url        = data.terraform_remote_state.infra.outputs.ecr_repository_url
}

resource "docker_image" "lambda_image" {
  name = "${local.ecr_repository_url}:latest"
  build {
    path = "../lambda"
    tag  = ["${local.ecr_repository_url}:latest"]
  }
}

resource "null_resource" "push_image" {
  provisioner "local-exec" {
    command = <<-EOT
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${split(":", local.ecr_repository_url)[0]}
      docker push ${local.ecr_repository_url}:latest
    EOT
  }

  depends_on = [
    docker_image.lambda_image
  ]
}

resource "aws_lambda_function" "sre_ha_lambda" {
  function_name = "${local.cluster_name}-lambda"
  role          = local.lambda_role_arn

  package_type = "Image"
  image_uri    = "${local.ecr_repository_url}:latest"

  environment {
    variables = {
      EKS_NAME = local.cluster_name
    }
  }

  depends_on = [
    null_resource.push_image
  ]
}

resource "aws_apigatewayv2_integration" "lambda_integration" {
  api_id = local.api_gateway_id

  integration_uri    = aws_lambda_function.sre_ha_lambda.invoke_arn
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
}

resource "aws_apigatewayv2_route" "lambda_route" {
  api_id = local.api_gateway_id

  route_key = "GET /"
  target    = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sre_ha_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${local.api_gateway_execution_arn}/*/*"
}
