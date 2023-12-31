resource "aws_security_group" "main" {
  name        = "${var.env}-${var.component}-sg"
  description = "${var.env}-${var.component}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "RDS"
    from_port   = 3306      #mysql port
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.component}-sg"
  }
}

resource "aws_db_subnet_group" "main" {                   #we need to create which subnet needs to provide subnet group
  name       = "${var.env}-${var.component}"
  subnet_ids = var.subnets

  tags = {
    Name = "${var.env}-${var.component}"
  }
}



resource "aws_rds_cluster" "main" {                                     #cluster is outbox it is like vpc virtual entry which is an virtual entity inside this need to create some instances
  cluster_identifier     = "${var.env}-${var.component}"
  engine                 = "aurora-mysql"
  engine_version         = "5.7.mysql_aurora.2.11.3"
  db_subnet_group_name   = aws_db_subnet_group.main.name
  database_name          = "dummy"
  master_username        = data.aws_ssm_parameter.master_username.value
  master_password        = data.aws_ssm_parameter.master_password.value
  vpc_security_group_ids = [aws_security_group.main.id]
  skip_final_snapshot    = true
}

resource "aws_rds_cluster_instance" "main" {
  count              = 1
  identifier         = "${var.env}-${var.component}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.main.id
  instance_class     = var.instance_class            #how many insatances did you want inside clister group
  engine             = aws_rds_cluster.main.engine
  engine_version     = aws_rds_cluster.main.engine_version
}