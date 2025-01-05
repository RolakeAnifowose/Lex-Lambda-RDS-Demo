/*resource "aws_iam_service_linked_role" "apprunner" {
  aws_service_name = "apprunner.amazonaws.com"
  description      = "Service Linked Role for App Runner"
}

resource "aws_apprunner_service" "animal-grooming" {
    depends_on = [aws_iam_service_linked_role.apprunner]

  service_name = "animal-grooming"
  source_configuration {
    # authentication_configuration {
    #   access_role_arn = aws_iam_role.apprunner-build-role.arn
    # }

    image_repository {
      image_configuration {
        port = 80
      }
      image_identifier      = "556298987240.dkr.ecr.us-east-1.amazonaws.com/appointment:latest"
      image_repository_type = "ECR_PUBLIC"
    }
    auto_deployments_enabled = false
  }

  instance_configuration {
    cpu               = 1024
    memory            = 2048
    instance_role_arn = aws_iam_role.apprunner-task-role.arn
  }

  network_configuration {
    ingress_configuration {
      is_publicly_accessible = true
    }
    egress_configuration {
      egress_type = "DEFAULT"
    }
  }



}


resource "aws_iam_role" "apprunner-task-role" {
  name = "apprunner-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "ECSRolePolicy"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["ssm:GetParameters"]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }

  tags = {
    tag-key = "apprunner-task-iam-role"
  }
}

resource "aws_iam_role" "apprunner-build-role" {
  name = "apprunner-build-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  ]

  tags = {
    tag-key = "apprunner-build-iam-role"
  }
}*/