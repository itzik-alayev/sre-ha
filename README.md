# sre-ha
A project consisting of 2 seperate Terraform deployments that provision resources on AWS.
- [TF] infra: Provisions core infrastructure resources -  VPC, EKS Cluster, API Gateway, IAM Roles, ECR Repository.

- [TF]deploy: Builds and pushes a Docker image that is used by a Lambda function which is also provisioned, creates a single endpoint in the API Gateway provisioned on `infra`.

- [Go] lambda: Golang code built for Lambda & API Gateway which gets authentication information for a cluster, lists all Pods in `kube-system` namespace and returns an `APIGatewayProxyResponse` object so we can see valid reponse when accessing the API Gateway.

## How to deploy?
Simply run `./deploy.sh` script.

In case you want to change variables related to Terraform, you'll need to create a file named `terraform.tfvars` in the desired directory (infra, deploy) and provide your own variables.

You can view all variables accepted by each Terraform on `variables.tf` in the corresponding directory.

## How to destory?
Simply run `./destroy.sh` script.