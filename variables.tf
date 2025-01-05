variable "latest_ami_id" {
  description = "AMI for EC2 instance"
  type        = string
  default     = ""
}

data "aws_ssm_parameter" "amazon_linux_2" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

locals {
  instance_ami = coalesce(var.latest_ami_id, data.aws_ssm_parameter.amazon_linux_2.value)
}