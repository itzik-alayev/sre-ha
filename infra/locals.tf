locals {
  number_of_azs = var.number_of_azs > length(data.aws_availability_zones.azs.names) ? length(data.aws_availability_zones.azs.names) : var.number_of_azs
}