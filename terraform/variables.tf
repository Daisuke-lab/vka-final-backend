

variable "lambda_iam_role" {
  default = "arn:aws:iam::555399571935:role/service-role/vka-product-search-role-mxj7mb8t"
}

variable "lambdas" {
  type = map(map(string))
  default = {
    get-categories = {
      function_name = "vka-product-categories"
      file_path     = "products/get_categories.py"
      runtime       = "python3.10"
    },
    get-product-details = {
      function_name = "vka-product-details"
      file_path     = "products/product_details.py"
      runtime       = "python3.10"
    },
    search-products = {
      function_name = "vka-product-search"
      file_path     = "products/search_products.py"
      runtime       = "python3.10"
    },
    add-cart-item = {
      function_name = "vka-cart-add-item"
      file_path     = "carts/add_item.mjs"
      runtime       = "nodejs22.x"
    },
    remove-cart-item = {
      function_name = "vka-cart-remove-item"
      file_path     = "carts/remove_item.mjs"
      runtime       = "nodejs22.x"
    },
    get-cart-items = {
      function_name = "vka-cart-get-items"
      file_path     = "carts/get_items.mjs"
      runtime       = "nodejs22.x"
    },
    update-cart-quantity = {
      function_name = "vka-cart-change-quantity"
      file_path     = "carts/change_quantity.mjs"
      runtime       = "nodejs22.x"
    },
    create-order = {
      function_name = "vka-order-create"
      file_path     = "orders/create_order.mjs"
      runtime       = "nodejs22.x"
    }
  }
}

variable "api_resources" {
  type = map(list(map(string)))
  default = {
    "/products": [{http_method: "GET", lambda_key = "search-products"}],
    "/products/categories": [{http_method: "GET", lambda_key = "get-categories"}],
    "/products/{category}/{id}": [{http_method: "GET", lambda_key = "get-product-details"}],
    "/orders": [{http_method: "POST", lambda_key = "create-order"}],
    "/carts": [
                {http_method: "GET", lambda_key = "get-cart-items"},
                {http_method: "PUT", lambda_key = "update-cart-quantity"},
                {http_method: "POST", lambda_key = "add-cart-item"},
                {http_method: "DELETE", lambda_key = "remove-cart-item"}]
  }
}