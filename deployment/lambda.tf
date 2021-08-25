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
    null_resource.build_push_image
  ]
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sre_ha_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${local.api_gateway_execution_arn}/*/*"
}
