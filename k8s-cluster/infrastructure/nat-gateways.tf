resource "aws_nat_gateway" "prj-eks" {
  count = 2

  depends_on = [aws_eip.prj-eks]

  allocation_id = aws_eip.prj-eks[count.index].id
  subnet_id     = aws_subnet.prj-eks-public[count.index].id

  tags = {
    Name = "${local.project_name_common}-eks-${substr(substr(aws_subnet.prj-eks-public[count.index].tags.Name, -5, -1), 0, 2)}-ng"
  }
}
