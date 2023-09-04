locals {
  vpc_name     = "vpc01-use1-${var.environment}"
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_subnet" "subnets_set" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

locals {
  cluster_name = "eks${var.cluster_num}-${var.region_short}-${var.environment}"
}

# see: https://github.com/terraform-aws-modules/terraform-aws-eks
module "eks" {
  source               = "terraform-aws-modules/eks/aws"
  version              = "18.31.2"

  cluster_name         = local.cluster_name
  cluster_version      = var.kubernetes_version
  subnet_ids           = var.subnet_ids
  enable_irsa          = true

  vpc_id               = var.vpc_id

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  eks_managed_node_groups = {
    first = {
      name          = "${local.cluster_name}-ng01"
      desired_size  = 3
      max_size      = var.node_groups_max_capacity
      min_size      = var.node_groups_min_capacity

      create_iam_role          = true
      iam_role_use_name_prefix = false
      iam_role_name            = "EKSNode"

      instance_types     = var.node_groups_instance_types

      create_security_group = true
      security_group_name = "${local.cluster_name}-sg01"
      security_group_rules = {
        computed_ingress_with_source_security_group_id = {
          description = "Managed node group security group"
          protocol = "-1"
          from_port = 0
          to_port = 0
          type = "ingress"
          self = true
        }
      }


      timeouts = {
        create: "45m",
        update: "45m",
        delete: "45m"
      }
    }
  }

  node_security_group_additional_rules = {
    ingress_self_all = {
      description = "Allow all ports/protocols between nodes"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      self        = true
    }
    egress_all = {
      description      = "Allow all egress from nodes"
      protocol         = "-1"
      from_port        = 0
      to_port          = 0
      type             = "egress"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::${var.account_id}:role/SSMRole"
      username = "SSMRole"
      groups   = ["system:masters"]
    },
  ]

  cluster_timeouts = {
    create: "45m",
    update: "45m",
    delete: "45m"
  }

}


resource "aws_security_group_rule" "bastion_access" {
  type                     = "ingress"
  description              = "Allow bastion host to connect for kubectl"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"

  security_group_id        = module.eks.cluster_security_group_id

  cidr_blocks  = [for s in data.aws_subnet.subnets_set : s.cidr_block]
}


output cluster_endpoint {
  value = module.eks.cluster_endpoint
}
