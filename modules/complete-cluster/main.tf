locals {
  eks_oidc_root_ca_thumbprint = replace(module.eks-cluster.oidc_provider_arn, "/.*id//", "")
}

module "vpc" {
  source    = "../vpc" # change to the correct one
  # source = "git::https://github.com/dasmeta/terraform.git//modules/vpc?ref=create-vpc-module"

  vpc_name            = var.vpc_name
  availability_zones  = var.availability_zones
  cidr                = var.cidr
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  public_subnet_tags  = var.public_subnet_tags
  private_subnet_tags = var.private_subnet_tags
}

module "eks-cluster" {
  # source = "git::https://github.com/dasmeta/terraform.git//modules/eks?ref=create-eks-module"
  # source = "github.com/dasmeta/terraform/modules"
  source = "../eks" # change to the correct one.

  cluster_name  = var.cluster_name
  vpc_id        = module.vpc.vpc_id
  subnets       = module.vpc.vpc_private_subnets
  # depends_on    = [module.vpc]

  manage_aws_auth = var.manage_aws_auth
  map_users = var.map_users
  worker_groups = var.worker_groups
  worker_groups_launch_template = var.worker_groups_launch_template
  workers_group_defaults = var.workers_group_defaults
}

module "cloudwatch-metrics" {
  # source = "git::https://github.com/dasmeta/terraform.git"
  # source = "git::https://github.com/dasmeta/terraform.git//modules/aws-cloudwatch-metrics"
  source = "../aws-cloudwatch-metrics" # change to the correct one.

  eks_oidc_root_ca_thumbprint = local.eks_oidc_root_ca_thumbprint
  oidc_provider_arn = module.eks-cluster.oidc_provider_arn
  cluster_name = var.cluster_name

  cluster_host = module.eks-cluster.host
  cluster_certificate = module.eks-cluster.certificate
  cluster_token = module.eks-cluster.token
}

module "alb-ingress-controller" {
  # source = "git::https://github.com/dasmeta/terraform.git"
  # source = "git::https://github.com/dasmeta/terraform.git//modules/aws-load-balancer-controller"

  source = "../aws-load-balancer-controller" # change to the correct one.

  cluster_name = var.cluster_name
  eks_oidc_root_ca_thumbprint = local.eks_oidc_root_ca_thumbprint
  oidc_provider_arn = module.eks-cluster.oidc_provider_arn
  create_alb_log_bucket = true
  alb_log_bucket_name = var.alb_log_bucket_name != "" ? var.alb_log_bucket_name : "${var.cluster_name}-ingress-controller-log-bucket"
  alb_log_bucket_prefix = var.alb_log_bucket_prefix != "" ? var.alb_log_bucket_prefix : var.cluster_name

  cluster_host = module.eks-cluster.host
  cluster_certificate = module.eks-cluster.certificate
  cluster_token = module.eks-cluster.token
}

module "fluent-bit" {
  # source = "git::https://github.com/dasmeta/terraform.git"
  source = "../fluent-bit"
  # source = "git::https://github.com/dasmeta/terraform.git//modules/fluent-bit"

  fluent_bit_name             = var.fluent_bit_name != "" ? var.fluent_bit_name : "${var.cluster_name}-fluent-bit"
  log_group_name              = var.log_group_name != "" ? var.log_group_name : "fluent-bit-cloudwatch-${var.cluster_name}"
  cluster_name                = var.cluster_name
  eks_oidc_root_ca_thumbprint = module.eks-cluster.eks_oidc_root_ca_thumbprint
  oidc_provider_arn           = module.eks-cluster.oidc_provider_arn

  cluster_host = module.eks-cluster.host
  cluster_certificate = module.eks-cluster.certificate
  cluster_token = module.eks-cluster.token
}

module "metrics-server" {
  # count = var.enable_metrics_server == true ? 1 : 0

  source = "../metrics-server"
  name = var.metrics_server_name != "" ? var.metrics_server_name : "${var.cluster_name}-metrics-server"

  cluster_host = module.eks-cluster.host
  cluster_certificate = module.eks-cluster.certificate
  cluster_token = module.eks-cluster.token
  cluster_name = var.cluster_name
}
