# --------------------------------------
# AWS variables

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "Desired AWS Region to deploy environment on"
}

# --------------------------------------
# VPC variables

variable "vpc_name" {
  type        = string
  default     = "sre-ha"
  description = "Desired VPC name"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "CIDR block to use for VPC"
}

variable "number_of_azs" {
  type        = number
  default     = 3
  description = "Number of Availability Zones to create subnets in"
}

variable "subnet_prefix_extension" {
  type        = number
  default     = 4
  description = "CIDR block bits extension to calculate CIDR blocks of each subnet."
}

variable "zone_offset" {
  type        = number
  default     = 8
  description = "CIDR block bits extension offset to calculate Public subnets, avoiding collisions with Private subnets."
}

# --------------------------------------
# EKS variables

variable "cluster_name" {
  type        = string
  default     = "sre-ha"
  description = "Desired EKS cluster name"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.20"
  description = "Kubernetes version that the EKS cluster is going to be deployed with"
}

# --------------------------------------
# SRE-Pool-Main nodegroup variables

variable "sre_pool_main_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 Instance type to use for SRE-Pool-Main nodepool."
}

variable "sre_pool_main_min_size" {
  type        = number
  default     = 3
  description = "Minimum worker nodes count for SRE-Pool-Main nodepool"
}

variable "sre_pool_main_max_size" {
  type        = number
  default     = 3
  description = "Maximum worker nodes count for SRE-Pool-Main nodepool"
}

variable "sre_pool_main_desired_size" {
  type        = number
  default     = 3
  description = "Desired worker nodes count for SRE-Pool-Main nodepool"
}

# --------------------------------------
# SRE-Pool-Sec nodegroup variables

variable "sre_pool_sec_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 Instance type to use for SRE-Pool-Main nodepool."
}

variable "sre_pool_sec_min_size" {
  type        = number
  default     = 3
  description = "Minimum worker nodes count for SRE-Pool-Main nodepool"
}

variable "sre_pool_sec_max_size" {
  type        = number
  default     = 3
  description = "Maximum worker nodes count for SRE-Pool-Main nodepool"
}

variable "sre_pool_sec_desired_size" {
  type        = number
  default     = 3
  description = "Desired worker nodes count for SRE-Pool-Main nodepool"
}
