locals {
  project_k8s_config_path    = var.project_k8s_config_path != "compute" ? var.project_k8s_config_path : "~/.kube/${var.project_name}"
  project_k8s_config_context = var.project_k8s_config_context != "compute" ? var.project_k8s_config_context : var.project_name
}
