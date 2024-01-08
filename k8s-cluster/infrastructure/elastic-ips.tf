resource "aws_eip" "prj-eks" {
  count = 2

  depends_on = [aws_internet_gateway.prj]

  tags = {
    Name = "${local.project_name_common}-eks-${substr(substr(aws_subnet.prj-eks-public[count.index].tags.Name, -5, -1), 0, 2)}-eip"
  }
}
