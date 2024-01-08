variable "aws_profile" {
  default = "dev"
  type    = string
}

variable "aws_region" {
  default = "us-west-2"
  type    = string
}

variable "project_name" {
  # consider that for common aws resources:
  # - vpc
  # - subnets
  # - eks elastic ips
  # - eks nat gateways
  # - eks roles
  # - eks node roles
  # the last number of the project_name will be remove
  # for example if the project_name is set to k8s-cluster-1
  # the common aws resources will use it as k8s-cluster
  default = "k8s-cluster"
  type    = string
}

variable "project_aws_vpc_cidr_block" {
  #Consider that:
  #- the project creates 6 subnets using a `/27`
  default = "10.0.64.0/18"
  type    = string
}


variable "project_aws_rds_allocated_storage" {
  # consider that the max_allocated_storage will have the same value as this
  default = 10
  type    = number
}

variable "project_aws_rds_engine" {
  default = "mysql"
  type    = string
}

variable "project_aws_rds_engine_version" {
  default = "8.0"
  type    = string
}

variable "project_aws_rds_instance_class" {
  default = "db.t3.micro"
  type    = string
}

variable "project_aws_rds_password" {
  # compute value will use random_string to generate a password
  default = "compute"
  type    = string
}

variable "project_aws_rds_port" {
  default = "3306"
  type    = string
}

variable "project_aws_rds_storage_type" {
  default = "gp2"
  type    = string
}

variable "project_aws_rds_username" {
  # compute value will transform the project_name to pascal case and use it
  default = "compute"
  type    = string
}

variable "project_aws_eks_ng_scaling_config_desired" {
  default = 1
  type    = number
}

variable "project_aws_eks_ng_scaling_config_max" {
  default = 1
  type    = number
}

variable "project_aws_eks_ng_scaling_config_min" {
  default = 1
  type    = number
}

variable "project_aws_eks_ng_ami_type" {
  default = "AL2_x86_64"
  type    = string
}

variable "project_aws_eks_ng_capacity_type" {
  default = "ON_DEMAND"
  type    = string
}

variable "project_aws_eks_ng_disk_size" {
  default = 20
  type    = number
}

variable "project_aws_eks_ng_instance_types" {
  default = ["m5.xlarge"]
  type    = list(string)
}
