
#RDS instance resource.

resource "aws_db_instance" "iops-terraform" {
  identifier            = var.identifier
  instance_class        = var.instance_class
  allocated_storage     = 10
  max_allocated_storage = 0 #to disable Storage Autoscaling.
  engine                = "mysql"
  engine_version        = "8.0.28"

  #credentials
  username = var.db_username
  password = data.aws_ssm_parameter.my_db_password.value

  #db conf
  db_name              = var.db_name
  parameter_group_name = var.parameter_group_name

  #network conf
  db_subnet_group_name   = aws_db_subnet_group.terr_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.iops-terraform-private-sg.id]
  publicly_accessible    = false
  skip_final_snapshot    = true

  backup_retention_period    = 0
  auto_minor_version_upgrade = false

  apply_immediately = true

}



#RDS Subnet group.


resource "aws_db_subnet_group" "terr_db_subnet_group" {
  name       = var.aws_db_subnet_group
  subnet_ids = [aws_subnet.iops-PrivateSubnet-A.id, aws_subnet.iops-PrivateSubnet-B.id]

  tags = {
    Name = var.tags2
  }
}

