variable "authorizer_name" {
  default = "vka-shopping-auth"
}


resource "aws_api_gateway_rest_api" "api_gateway" {
  name = "vka-api-gateway"
  endpoint_configuration {
    types = ["REGIONAL"]
  }

  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "example2"
      version = "1.0"
    }
    components = {
      "securitySchemes" : {
        "${var.authorizer_name}" : {
          "type" : "apiKey",
          "name" : "Authorization",
          "in" : "header",
          "x-amazon-apigateway-authtype" : "cognito_user_pools",
          "x-amazon-apigateway-authorizer" : {
            "type" : "cognito_user_pools",
            "providerARNs" : [
              aws_cognito_user_pool.vka_cognito.arn
            ]
          }
        }
    } },
    paths : {
      for path, integrations in var.api_resources : path => merge({
        for integration in integrations
        : lower(integration.http_method) => {
          x-amazon-apigateway-integration : {
            httpMethod : "POST"
            uri : aws_lambda_function.deploy[integration.lambda_key].invoke_arn
            type : "aws_proxy"
          },
          security : integration.auth_required ? [{ "${var.authorizer_name}" : [] }] : []
        }
        },
        {
          "options" = jsondecode(file("open_api_cors_policy.json"))
        }
      )
    }
  })
}

# resource "aws_api_gateway_authorizer" "cognito" {
#   name            = var.authorizer_name
#   rest_api_id     = aws_api_gateway_rest_api.api_gateway.id
#   identity_source = "method.request.header.Authorization"
#   type            = "COGNITO_USER_POOLS"
#   provider_arns   = [aws_cognito_user_pool.vka_cognito.arn]
# }

