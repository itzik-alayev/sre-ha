resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "${var.cluster_name}-apigw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_gateway" {
  api_id = aws_apigatewayv2_api.api_gateway.id

  name        = var.cluster_name
  auto_deploy = true
}