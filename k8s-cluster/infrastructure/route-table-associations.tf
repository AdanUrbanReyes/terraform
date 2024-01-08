resource "aws_route_table_association" "prj-public-internet" {
  count = 2

  subnet_id      = aws_subnet.prj-eks-public[count.index].id
  route_table_id = aws_route_table.prj-public-internet.id
}

resource "aws_route_table_association" "prj-private-internet" {
  count = 2

  subnet_id      = aws_subnet.prj-eks-private[count.index].id
  route_table_id = aws_route_table.prj-private-internet[count.index].id
}
