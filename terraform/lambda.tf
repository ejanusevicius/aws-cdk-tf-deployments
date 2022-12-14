resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda_execution_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "archive_file" "helloworld_zip" {
  type        = "zip"
  source_file = "../lambda_functions/hello_world.py"
  output_path = "/lambda_zipped/helloworld.zip"
}

resource "aws_lambda_function" "helloworld" {
  depends_on = [
    data.archive_file.helloworld_zip
  ]
  function_name    = "terraform-hello-world"
  filename         = data.archive_file.helloworld_zip.output_path
  handler          = "hello_world.lambda_handler"
  source_code_hash = filebase64sha256(data.archive_file.helloworld_zip.output_path)
  role             = aws_iam_role.lambda_execution_role.arn
  runtime          = "python3.9"
  memory_size      = 128
  timeout          = 10
  environment {
    variables = {
      deployment_mechanism = "Terraform"
    }
  }
}
