locals {
  api_gateway_id            = data.terraform_remote_state.infra.outputs.api_gateway_id
  api_gateway_execution_arn = data.terraform_remote_state.infra.outputs.api_gateway_execution_arn
  cluster_name              = data.terraform_remote_state.infra.outputs.cluster_name
  lambda_role_arn           = data.terraform_remote_state.infra.outputs.lambda_role_arn
  ecr_repository_url        = data.terraform_remote_state.infra.outputs.ecr_repository_url
}