resource "aws_ssm_parameter" "db-url" {
  name  = "/appointment-app/prod/db-url"
  type  = "String"
  value = "terraform-20250102200105680300000001.clacmsizwwve.us-east-1.rds.amazonaws.com"
  tier  = "Standard"
}

resource "aws_ssm_parameter" "db-user" {
  name  = "/appointment-app/prod/db-user"
  type  = "String"
  value = "admin"
  tier  = "Standard"
}

resource "aws_ssm_parameter" "db-password" {
  name  = "/appointment-app/prod/db-password"
  type  = "SecureString"
  value = "qU21OXk8"
  tier  = "Standard"
}

resource "aws_ssm_parameter" "db-database" {
  name      = "/appointment-app/prod/db-database"
  type      = "String"
  value     = "pets"
  data_type = "text"
  tier      = "Standard"
}