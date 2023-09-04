module "eks_cluster" {
  source = "./modules/cluster"

  environment = var.environment
  account_id  = data.aws_caller_identity.current.account_id

  cluster_num                = "01"
  region_short               = "use1"
  kubernetes_version         = var.kubernetes_version
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnets
  node_groups_max_capacity   = var.node_groups_max_capacity
  node_groups_min_capacity   = var.node_groups_min_capacity
  node_groups_instance_types = var.node_groups_instance_types
}

