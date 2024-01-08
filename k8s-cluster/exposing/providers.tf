provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}

provider "kubernetes" {
  config_path    = local.project_k8s_config_path
  config_context = local.project_k8s_config_context
}
