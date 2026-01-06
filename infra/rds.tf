resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "csye6225-db-subnet-group"
  subnet_ids = aws_subnet.private_subnets[*].id

  tags = {
    Name = "RDS Subnet Group"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "rds-db-sg"
  description = "Allow EC2 access to RDS"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}

resource "aws_db_parameter_group" "postgres_params" {
  name        = "csye6225-postgres15-params-${var.profile}"
  family      = "postgres15"
  description = "Custom parameter group for CSYE6225 PostgreSQL"

  #Example: Enable logging slow queries
  parameter {
    name  = "log_min_duration_statement"
    value = "500"
  }

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    name  = "log_disconnections"
    value = "1"
  }

  parameter {
    name  = "log_statement"
    value = "none"
  }

  tags = {
    Name = "Custom PG"
  }
}

resource "aws_db_instance" "webapp_db" {
  identifier             = "csye6225"
  engine                 = "postgres"
  engine_version         = "15"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "csye6225"
  username               = var.db_username
  password               = random_password.db_password.result
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  parameter_group_name   = aws_db_parameter_group.postgres_params.name
  skip_final_snapshot    = true
  publicly_accessible    = false
  multi_az               = false
  deletion_protection    = false
  kms_key_id             = aws_kms_key.rds_kms_key.arn
  storage_encrypted      = true

  tags = {
    Name = "Assignment08-RDS"
  }
}


output "rds_endpoint" {
  value = aws_db_instance.webapp_db.endpoint
}
