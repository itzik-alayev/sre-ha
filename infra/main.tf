data "aws_availability_zones" "azs" {
  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

locals {
  number_of_azs = var.number_of_azs > length(data.aws_availability_zones.azs.names) ? length(data.aws_availability_zones.azs.names) : var.number_of_azs
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs = slice(data.aws_availability_zones.azs.names, 0, local.number_of_azs)

  private_subnets = [
    for zone_id in slice(data.aws_availability_zones.azs.zone_ids, 0, local.number_of_azs) :
    cidrsubnet(var.vpc_cidr, var.subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) - 1)
  ]

  public_subnets = [
    for zone_id in slice(data.aws_availability_zones.azs.zone_ids, 0, local.number_of_azs) :
    cidrsubnet(var.vpc_cidr, var.subnet_prefix_extension, tonumber(substr(zone_id, length(zone_id) - 1, 1)) + var.zone_offset - 1)
  ]

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  tags = {
    Name        = var.vpc_name
    environment = var.cluster_name
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
    environment                                 = var.cluster_name
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
    environment                                 = var.cluster_name
  }
}

resource "aws_iam_role" "eks_lambda" {
  name = "eks_lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
      }
    ]
  })

  tags = {
    Name = "${var.cluster_name}-lambda-role"
  }
}

resource "aws_iam_role_policy" "eks_lambda_iam_policy" {
  name = "eks_lambda_iam_policy"
  role = aws_iam_role.eks_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:GetCallerIdentity",
          "eks:DescribeCluster"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  depends_on      = [module.vpc]
  version         = "17.1.0"
  cluster_name    = var.cluster_name
  cluster_version = var.kubernetes_version

  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  enable_irsa     = true
  manage_aws_auth = true

  map_roles = [{
    rolearn  = aws_iam_role.eks_lambda.arn
    username = "lambda"
    groups   = ["system:authenticated"]
  }]

  node_groups = {
    sre-pool-main = {
      instance_types   = [var.sre_pool_main_instance_type]
      min_capacity     = var.sre_pool_main_min_size
      max_capacity     = var.sre_pool_main_max_size
      desired_capacity = var.sre_pool_main_desired_size
    }

    sre-pool-sec = {
      instance_types   = [var.sre_pool_sec_instance_type]
      min_capacity     = var.sre_pool_sec_min_size
      max_capacity     = var.sre_pool_sec_max_size
      desired_capacity = var.sre_pool_sec_desired_size
    }
  }

  write_kubeconfig = false
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

resource "aws_apigatewayv2_api" "api_gateway" {
  name          = "${var.cluster_name}-apigw"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_stage" "api_gateway" {
  api_id = aws_apigatewayv2_api.api_gateway.id

  name        = var.cluster_name
  auto_deploy = true
}

resource "kubernetes_role" "pod_reader" {
  metadata {
    name      = "pod-reader"
    namespace = "kube-system"
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["list"]
  }
}

resource "kubernetes_role_binding" "lambda_pod_reader" {
  metadata {
    name      = "lambda-pod-reader"
    namespace = "kube-system"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "pod-reader"
  }
  subject {
    kind      = "User"
    name      = "lambda"
    api_group = "rbac.authorization.k8s.io"
  }
}

resource "aws_ecr_repository" "lambda_image" {
  name = "${var.cluster_name}-lambda"
}
