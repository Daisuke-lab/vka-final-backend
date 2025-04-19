variable categories_filename {
  default = "get_categories"
}
data "archive_file" "init_get_categories" {
  type        = "zip"
  source_file = "${dirname(path.cwd)}/products/${var.categories_filename}.py"
  output_path = "${dirname(path.cwd)}/outputs/${var.categories_filename}.zip"
}

resource "aws_lambda_function" "get_categories" {
  function_name    = "vka-product-categories"
  handler          = "${var.categories_filename}.lambda_handler"
  runtime          = "python3.10"
  filename         = data.archive_file.init_get_categories.output_path
  source_code_hash = data.archive_file.init_get_categories.output_base64sha256
  role             = var.lambda_iam_role
}