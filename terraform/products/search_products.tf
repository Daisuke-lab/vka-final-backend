variable search_filename {
  default = "search_products"
}
data "archive_file" "init_search_products" {
  type        = "zip"
  source_file = "${dirname(path.cwd)}/products/${var.search_filename}.py"
  output_path = "${dirname(path.cwd)}/outputs/${var.search_filename}.zip"
}

resource "aws_lambda_function" "search_products" {
  function_name    = "vka-product-search"
  handler          = "${var.search_filename}.lambda_handler"
  runtime          = "python3.10"
  filename         = data.archive_file.init_search_products.output_path
  source_code_hash = data.archive_file.init_search_products.output_base64sha256
  role             = var.lambda_iam_role
}