

variable "lambda_iam_role" {
    default = "arn:aws:iam::555399571935:role/service-role/vka-product-search-role-mxj7mb8t"
}

variable "lambdas" {
    type = map(map(string))
    default = {
        vka-product-categories: {file_path: "products/get_categories.py", runtime: "python3.10"},
        vka-product-details: {file_path: "products/product_details.py", runtime: "python3.10"},
        vka-product-search: {file_path: "products/search_products.py", runtime: "python3.10"},
        vka-cart-add-item: {file_path: "carts/add_item.mjs", runtime: "nodejs22.x"},
        vka-cart-remove-item: {file_path: "carts/remove_item.mjs", runtime: "nodejs22.x"},
        vka-cart-get-items: {file_path: "carts/get_items.mjs", runtime: "nodejs22.x"},
        vka-cart-change-quantity: {file_path: "carts/change_quantity.mjs", runtime: "nodejs22.x"},
        vka-order-create: {file_path: "orders/create_order.mjs", runtime: "nodejs22.x"},
    }
}