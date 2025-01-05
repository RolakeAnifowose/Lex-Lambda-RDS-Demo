resource "aws_instance" "appointment" {
  instance_type        = "t3.micro"
  ami                  = local.instance_ami
  user_data            = file("script.sh")
  iam_instance_profile = aws_iam_instance_profile.ec2.name
}

resource "aws_iam_role" "ec2" {
  name               = "ec2"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  inline_policy {
    name   = "EC2RolePolicy"
    policy = data.aws_iam_policy_document.ec2_inline_policy.json
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "ec2_inline_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:CompleteLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:InitiateLayerUpload",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_instance_profile" "ec2" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2.name
}