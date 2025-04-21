terraform state mv aws_lambda_function.deploy[\"vka-product-categories\"] aws_lambda_function.deploy[\"get-categories\"]
terraform state mv aws_lambda_function.deploy[\"vka-product-details\"] aws_lambda_function.deploy[\"get-product-details\"]
terraform state mv aws_lambda_function.deploy[\"vka-product-search\"] aws_lambda_function.deploy[\"search-products\"]
terraform state mv aws_lambda_function.deploy[\"vka-cart-add-item\"] aws_lambda_function.deploy[\"add-cart-item\"]
terraform state mv aws_lambda_function.deploy[\"vka-cart-remove-item\"] aws_lambda_function.deploy[\"remove-cart-item\"]
terraform state mv aws_lambda_function.deploy[\"vka-cart-get-items\"] aws_lambda_function.deploy[\"get-cart-items\"]
terraform state mv aws_lambda_function.deploy[\"vka-cart-change-quantity\"] aws_lambda_function.deploy[\"update-cart-quantity\"]
terraform state mv aws_lambda_function.deploy[\"vka-order-create\"] aws_lambda_function.deploy[\"create-order\"]



terraform import aws_dynamodb_table.product_table ProductTable
terraform import aws_dynamodb_table.user_table UserTable
terraform import aws_s3_bucket.frontend vka-frontend
terraform import aws_s3_bucket.images vka-images 
terraform import aws_cloudfront_distribution.frontned_cache E1NW830YWQJV18
terraform import aws_s3_bucket_website_configuration.static vka-frontend
terraform import aws_api_gateway_rest_api.api_gateway yddwsntpec


# resources
terraform import aws_api_gateway_resource.root yddwsntpec/bkqbo1f4if
terraform import aws_api_gateway_resource.nest yddwsntpec/soorcs

terraform import aws_cognito_user_pool.RESOUCE_NAME USER_POOL_NAME

terraform import aws_api_gateway_authorizer.cognito /v3lrcd