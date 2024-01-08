resource "aws_route_table" "prj-public-internet" {
  vpc_id = aws_vpc.prj.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prj.id
  }

  tags = {
    Name = "${local.project_name_common}-public-internet-rt"
  }
}

resource "aws_route_table" "prj-private-internet" {
  count = 2

  vpc_id = aws_vpc.prj.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.prj-eks[count.index].id
  }

  tags = {
    Name = "${local.project_name_common}-private-internet-${substr(substr(aws_nat_gateway.prj-eks[count.index].tags.Name, -5, -1), 0, 2)}-rt"
  }
}
