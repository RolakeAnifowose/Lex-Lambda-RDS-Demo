resource "aws_lambda_function" "appointment" {
  filename      = "lambda_function.zip"
  function_name = "appointment"
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda-role.arn
  layers        = [aws_lambda_layer_version.appointment.arn]
}

resource "aws_iam_role" "lambda-role" {
  name = "lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name = "LambdaRolePolicy"
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
    tag-key = "lambda-iam-role"
  }
}

resource "aws_lambda_permission" "lex_lambda" {
  statement_id  = "lex-bot-resource-policy"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.appointment.function_name
  principal     = "lexv2.amazonaws.com"
  #source_arn    = "${aws_lexv2models_bot.AppointmentBot.arn}/*"
  source_arn = "arn:aws:lex:us-east-1:556298987240:bot-alias/DQPPTSKBG3/TSTALIASID"
}