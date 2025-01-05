resource "aws_db_instance" "appointment" {
  db_name             = "appointment"
  engine              = "mysql"
  engine_version      = "8.0.32"
  username            = "admin"
  password            = "qU21OXk8"
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  publicly_accessible = true
  skip_final_snapshot = true
  storage_encrypted   = true
}