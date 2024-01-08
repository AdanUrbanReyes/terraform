variable "aws_profile" {
  default = "dev"
  type    = string
}

variable "aws_region" {
  default = "us-west-2"
  type    = string
}

variable "project_name" {
  type = string
}

variable "project_k8s_config_path" {
  # compute value will transform the project_name to pascal case and use it
  default = "compute"
  type    = string
}

variable "project_k8s_config_context" {
  # compute value will use the project_name as the config context
  default = "compute"
  type    = string
}

variable "project_route53_zone_name" {
  type = string
}

variable "project_route53_zone_id" {
  type = string
}
