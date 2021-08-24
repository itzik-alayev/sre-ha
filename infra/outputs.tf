output "aws_eks_cluster_context" {
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name}"
  description = "AWS CLI command to get 'kubectl' context to the EKS cluster"
}

output "cluster_name" {
  value       = var.cluster_name
  description = "AWS EKS cluster name to share with 'deploy' terraform on later stage"
}

output "api_gateway_id" {
  value       = aws_apigatewayv2_api.api_gateway.id
  description = "AWS API Gateway ID to share with 'deploy' terraform on later stage"
}

output "api_gateway_execution_arn" {
  value       = aws_apigatewayv2_api.api_gateway.execution_arn
  description = "AWS API Gateway execution ARN to share with 'deploy' terraform on later stage"
}

output "lambda_role_arn" {
  value       = aws_iam_role.eks_lambda.arn
  description = "AWS IAM Role ARN that is going to be used in 'deploy' terraform's Lambda function execution on later stage"
}

output "ecr_repository_url" {
  value = aws_ecr_repository.lambda_image.repository_url
}
