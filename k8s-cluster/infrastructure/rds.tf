resource "random_string" "prj-db-pwd" {
  length           = 15
  min_lower        = 2
  min_upper        = 5
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

data "aws_subnets" "prj-db" {
  depends_on = [aws_vpc.prj, aws_subnet.prj-db]

  filter {
    name   = "vpc-id"
    values = [aws_vpc.prj.id]
  }

  tags = {
    Name = "*-db-*"
    Tier = "private"
  }
}

resource "aws_db_subnet_group" "prj" {
  name        = "${local.project_name_common}-rds-sn-g"
  description = "Subnets for databases"
  subnet_ids  = data.aws_subnets.prj-db.ids

  tags = {
    Name = "${local.project_name_common}-rds-sn-g"
  }
}

resource "aws_security_group" "prj-db" {
  name        = "${local.project_name_common}-db-sg"
  description = "Allow database traffic"
  vpc_id      = aws_vpc.prj.id

  ingress {
    description = "Database for VPC"
    from_port   = var.project_aws_rds_port
    to_port     = var.project_aws_rds_port
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.prj.cidr_block]
  }

  egress {
    description = "Database for VPC"
    from_port   = var.project_aws_rds_port
    to_port     = var.project_aws_rds_port
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.prj.cidr_block]
  }
}

resource "aws_db_instance" "prj-rds" {
  allocated_storage                   = var.project_aws_rds_allocated_storage
  allow_major_version_upgrade         = true
  apply_immediately                   = true
  auto_minor_version_upgrade          = true
  db_subnet_group_name                = aws_db_subnet_group.prj.name
  engine                              = var.project_aws_rds_engine
  engine_version                      = var.project_aws_rds_engine_version
  iam_database_authentication_enabled = true
  identifier                          = "${var.project_name}-rds"
  instance_class                      = var.project_aws_rds_instance_class
  maintenance_window                  = "Mon:00:00-Mon:03:00"
  max_allocated_storage               = var.project_aws_rds_allocated_storage
  multi_az                            = false
  password                            = local.project_aws_rds_password
  port                                = var.project_aws_rds_port
  publicly_accessible                 = false
  skip_final_snapshot                 = true
  storage_encrypted                   = true
  storage_type                        = var.project_aws_rds_storage_type
  username                            = local.project_aws_rds_username
  vpc_security_group_ids              = [aws_security_group.prj-db.id]
}
