resource "aws_internet_gateway" "prj" {
  vpc_id = aws_vpc.prj.id

  tags = {
    Name = "${local.project_name_common}-ig"
  }
}
