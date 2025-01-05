resource "aws_lambda_layer_version" "appointment" {
  layer_name               = "appointment"
  filename                 = "pymysql_layer.zip"
  compatible_architectures = ["x86_64"]
  compatible_runtimes      = ["python3.8"]
}