

resource "aws_cognito_user_pool" "vka_cognito" {
  auto_verified_attributes = [
    "email",
  ]
  name           = "User_pool_otkgxi"
  user_pool_tier = "ESSENTIALS"
  username_attributes = [
    "email",
  ]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  password_policy {
    minimum_length                   = 8
    password_history_size            = 0
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }


  sign_in_policy {
    allowed_first_auth_factors = [
      "PASSWORD",
    ]
  }

  username_configuration {
    case_sensitive = false
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }


  # Adding Lambda trigger using lambda_config
  lambda_config {
    post_authentication = aws_lambda_function.deploy["subscribe-mail"].arn
  }
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  name         = "vka-shopping-user-pool"
  user_pool_id = aws_cognito_user_pool.vka_cognito.id
  callback_urls = [
    "http://localhost:3000/callback",
  "https://${aws_cloudfront_distribution.frontend_cache.domain_name}/callback"]
  logout_urls = [
    "http://localhost:3000",
  "https://${aws_cloudfront_distribution.frontend_cache.domain_name}"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
  explicit_auth_flows                  = ["ALLOW_USER_AUTH", "ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_CUSTOM_AUTH"]
  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
  access_token_validity  = 60   # in minutes
id_token_validity      = 60   # in minutes
refresh_token_validity = 30   # in days
generate_secret = true
}