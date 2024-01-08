locals {
  project_name_common      = try("${replace(var.project_name, regex("-?\\d+$", var.project_name), "")}", var.project_name)
  project_aws_rds_password = var.project_aws_rds_password != "compute" ? var.project_aws_rds_password : random_string.prj-db-pwd.result
  project_aws_rds_username = var.project_aws_rds_username != "compute" ? var.project_aws_rds_username : join("", [for word in split("-", var.project_name) : title(word)])
}
