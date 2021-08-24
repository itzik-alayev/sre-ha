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
