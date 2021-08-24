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