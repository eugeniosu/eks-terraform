data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}
#data "aws_region" "current" {}

variable "vpc_name" {
  type = string
}

variable "vpc_region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "vpc_private_subnets" {
  type = list(any)
}

variable "vpc_public_subnets" {
  type = list(any)
}

variable "kubernetes_version" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "node_groups_max_capacity" {
  type = number
}

variable "node_groups_min_capacity" {
  type = number
}

variable "node_groups_instance_types" {
  type = list(any)
}

