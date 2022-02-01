resource "aws_db_subnet_group" "db-subnet-group" {
  name        = "database-subnet"
  subnet_ids  = [for subnet in aws_subnet.db_private : subnet.id]
  description = "Subnet group for Database"
  tags = {
    Name = "db subnet group"
  }
}

resource "aws_db_instance" "database_demo" {
  instance_class                      = var.databaseInstanceVariable
  allocated_storage                   = 20
  engine                              = "mysql"
  engine_version                      = "8.0"
  identifier                          = "${var.infra_env}-${var.database_name}"
  name                                = var.database_name
  username                            = var.database_username
  password                            = var.database_password
  parameter_group_name                = "default.mysql8.0"
  skip_final_snapshot                 = true
  db_subnet_group_name                = aws_db_subnet_group.db-subnet-group.id
  apply_immediately                   = true
  iam_database_authentication_enabled = true
  publicly_accessible                 = false
  /*  performance_insights_enabled        = true */
  /* iops =  1000*/
  /* storage_type = "io1" */
  vpc_security_group_ids = ["${aws_security_group.database_security_group.id}"]

}
