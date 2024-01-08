resource "aws_vpc" "prj" {
  cidr_block           = var.project_aws_vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "${local.project_name_common}-vpc"
  }
}
