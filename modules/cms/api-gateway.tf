locals {
  api_gateway_name = "semantic-api"
  route_path       = "predict"
}

#################################
# API Gateway
#################################
resource "aws_api_gateway_rest_api" "my_api" {
  name        = local.api_gateway_name
  description = "API Gateway for my Lambda function"
}

resource "aws_api_gateway_resource" "images_resource" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  parent_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  path_part   = local.route_path
  depends_on = [
    aws_api_gateway_rest_api.my_api
  ]
}


# Authorizer
resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  name            = "cognito-authorizer"
  rest_api_id     = aws_api_gateway_rest_api.my_api.id
  provider_arns   = [aws_cognito_user_pool.user_pool.arn]
  identity_source = "method.request.header.Authorization"
  type            = "COGNITO_USER_POOLS"
  depends_on = [
    aws_api_gateway_rest_api.my_api,
    aws_cognito_user_pool.user_pool
  ]

}

resource "aws_api_gateway_method" "images_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_resource.images_resource.id
  http_method   = "POST"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
  depends_on = [
    aws_api_gateway_resource.images_resource
  ]
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.my_api.id
  resource_id             = aws_api_gateway_resource.images_resource.id
  http_method             = aws_api_gateway_method.images_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
  depends_on = [
    aws_api_gateway_method.images_method,
  ]

}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.my_api.execution_arn}/*/*"
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
  ]
}

# Method response
resource "aws_api_gateway_method_response" "get_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.images_resource.id
  http_method = aws_api_gateway_method.images_method.http_method
  status_code = "200"
}

# Integration response
resource "aws_api_gateway_integration_response" "lambda_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_resource.images_resource.id
  http_method = aws_api_gateway_method.images_method.http_method
  status_code = aws_api_gateway_method_response.get_response.status_code

  depends_on = [
    aws_api_gateway_integration.lambda_integration
  ]
}

#Deploy all resources
resource "aws_api_gateway_deployment" "mydeployment" {
  depends_on = [
    aws_api_gateway_resource.images_resource,
    aws_api_gateway_integration.lambda_integration,
    aws_api_gateway_integration_response.lambda_integration_response,
    aws_api_gateway_method.images_method,
    aws_api_gateway_method_response.get_response
  ]
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  stage_name  = "dev"
}

