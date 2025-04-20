#terraform import module.products.aws_lambda_function.get_categories vka-product-categories
#terraform import module.products.aws_lambda_function.search_products vka-product-search
#terraform import module.products.aws_lambda_function.product_details vka-product-details
#terraform import module.carts.aws_lambda_function.add_item vka-cart-add-item
#terraform import module.carts.aws_lambda_function.remove_item vka-cart-remove-item
#terraform import module.carts.aws_lambda_function.get_items vka-cart-get-items
#terraform import module.carts.aws_lambda_function.change_quantity vka-cart-change-quantity
terraform import module.orders.aws_lambda_function.create_order vka-order-create

terraform state mv module.products.aws_lambda_function.get_categories aws_lambda_function.deploy[0]
terraform state mv module.products.aws_lambda_function.search_products aws_lambda_function.deploy[1]
terraform state mv module.products.aws_lambda_function.product_details aws_lambda_function.deploy[2]

terraform state mv module.orders.aws_lambda_function.create_order aws_lambda_function.deploy[\"vka-order-create\"] 