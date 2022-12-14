data "aws_iam_policy_document" "apigateway_sts_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "api_gateway_execution_role" {
  name               = "terraform-api-gateway-role"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.apigateway_sts_policy.json
}

resource "aws_api_gateway_rest_api" "api_gateway" {
  name        = "terraform-workshop-api-gateway"
  description = "Deployed via Terraform"
}

resource "aws_api_gateway_resource" "messageResource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "message"
}

resource "aws_api_gateway_method" "messageGetMethod" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_resource.messageResource.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
}

resource "aws_api_gateway_integration" "integration" {
  http_method             = aws_api_gateway_method.messageGetMethod.http_method
  resource_id             = aws_api_gateway_resource.messageResource.id
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.helloworld.invoke_arn
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.helloworld.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api_gateway.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "employees_rest_api_deployment" {
  depends_on = [
    aws_api_gateway_method.messageGetMethod,
    aws_api_gateway_integration.integration
  ]
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = "prod"
  variables = {
    deployed_at = timestamp()
  }
}
