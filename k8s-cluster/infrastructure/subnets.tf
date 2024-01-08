data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "prj-db" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "${regex("\\d+.\\d+.\\d+", var.project_aws_vpc_cidr_block)}.${32 * count.index}/27"
  vpc_id            = aws_vpc.prj.id

  tags = {
    Name = "${local.project_name_common}-db-${substr(data.aws_availability_zones.available.names[count.index], -2, -1)}-sn"
    Tier = "private"
  }
}

resource "aws_subnet" "prj-eks-public" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "${regex("\\d+.\\d+.\\d+", var.project_aws_vpc_cidr_block)}.${32 * (count.index + 2)}/27"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.prj.id

  tags = {
    Name                                            = "${local.project_name_common}-eks-public-${substr(data.aws_availability_zones.available.names[count.index], -2, -1)}-sn"
    Tier                                            = "public"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
    "kubernetes.io/role/elb"                        = 1
  }
}

resource "aws_subnet" "prj-eks-private" {
  count = 2

  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = "${regex("\\d+.\\d+.\\d+", var.project_aws_vpc_cidr_block)}.${32 * (count.index + 4)}/27"
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.prj.id

  tags = {
    Name                                            = "${local.project_name_common}-eks-private-${substr(data.aws_availability_zones.available.names[count.index], -2, -1)}-sn"
    Tier                                            = "private"
    "kubernetes.io/cluster/${var.project_name}-eks" = "shared"
    "kubernetes.io/role/internal-elb"               = 1
  }
}
