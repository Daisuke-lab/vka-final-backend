variable product_details {
  default = "product_details"
}
data "archive_file" "init_product_details" {
  type        = "zip"
  source_file = "${dirname(path.cwd)}/products/${var.product_details}.py"
  output_path = "${dirname(path.cwd)}/outputs/${var.product_details}.zip"
}

resource "aws_lambda_function" "product_details" {
  function_name    = "vka-product-details"
  handler          = "${var.product_details}.lambda_handler"
  runtime          = "python3.10"
  filename         = data.archive_file.init_product_details.output_path
  source_code_hash = data.archive_file.init_product_details.output_base64sha256
  role             = var.lambda_iam_role
}