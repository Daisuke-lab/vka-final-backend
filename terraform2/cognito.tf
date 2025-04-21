resource "aws_cognito_user_pool" "vka_cognito" {
    name = "User_pool_otkgxi"
    mfa_configuration = "OFF"
    alias_attributes           = ["email"]
    auto_verified_attributes   = ["email"]
    password_policy {
    minimum_length    = 8
        require_uppercase = true
        require_lowercase = true
        require_numbers   = true
        require_symbols   = true
    }

    schema {
        name     = "email"
        required = true
        attribute_data_type = "String"
    }

     email_configuration {
        email_sending_account = "COGNITO_DEFAULT"
    }

    # Adding Lambda trigger using lambda_config
    lambda_config {
        post_authentication = var.lambdas2.post_authentication_lambda
    }
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  name                                 = "vka-shopping-user-pool"
  user_pool_id                         = aws_cognito_user_pool.pool.id
  callback_urls                        = [
    "http://localhost:3000/callback",
   "${var.cloudfront_domain}/callback"]
  logout_urls                          = [
    "http://localhost:3000", 
    var.cloudfront_domain]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
}