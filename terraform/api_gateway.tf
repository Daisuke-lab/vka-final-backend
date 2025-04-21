resource "aws_api_gateway_rest_api" "api_gateway" {
  name                         = "vka-api-gateway"
  endpoint_configuration {
        types            = ["REGIONAL"]
    }
}

resource "aws_api_gateway_rest_api" "api_gateway2" {
  name                         = "vka-api-gateway2"
  endpoint_configuration {
        types            = ["REGIONAL"]
    }

    body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "example"
      version = "1.0"
    }
    paths: {
        for path, integrations in var.api_resources :path => merge({
            for integration in integrations
                :lower(integration.http_method) => {
                    x-amazon-apigateway-integration: {
                        httpMethod: integration.http_method
                        uri: aws_lambda_function.deploy[integration.lambda_key].invoke_arn
                        type: "aws"
                    }
                }
            },
            {
            "options" = jsondecode(file("cors_policy.json"))
            }
            )
        }
})
}

resource "aws_api_gateway_authorizer" "cognito" {
  name                   = "vka-shopping-auth"
  rest_api_id           = aws_api_gateway_rest_api.api_gateway2.id
  identity_source       = "method.request.header.Authorization"
  type                  = "COGNITO_USER_POOLS"
  provider_arns         = [""]
}

