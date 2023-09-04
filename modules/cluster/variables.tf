variable "environment" {
  type    = string
}

variable "account_id" {
  type    = string
}

variable "cluster_num" {
  type = string
}

variable "region_short" {
  type = string
}

variable "kubernetes_version" {
  type = string
}

variable "subnet_ids" {
  type = list
}

variable "vpc_id" {
  type = string
}

variable "node_groups_max_capacity" {
  type = number
}

variable "node_groups_min_capacity" {
  type = number
}

variable "node_groups_instance_types" {
  type = list
}

