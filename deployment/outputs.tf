output "api_gateway_url" {
  value       = "https://${local.api_gateway_id}.execute-api.${var.region}.amazonaws.com/${local.cluster_name}/"
  description = "AWS API Gateway URL to access the Lambda function"
}
