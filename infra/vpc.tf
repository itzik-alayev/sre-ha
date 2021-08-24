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