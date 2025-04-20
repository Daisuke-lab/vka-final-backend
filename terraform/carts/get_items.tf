variable get_items_filename {
  default = "get_items"
}

data "archive_file" "init_get_items" {
  type        = "zip"
  source_file = "${dirname(path.cwd)}/carts/${var.get_items_filename}.mjs"
  output_path = "${dirname(path.cwd)}/outputs/${var.get_items_filename}.zip"

}

resource "aws_lambda_function" "get_items" {
  function_name    = "vka-cart-get-items"
  handler          = "${var.get_items_filename}.handler"
  runtime          = "nodejs22.x"
  filename         = data.archive_file.init_get_items.output_path
  source_code_hash = data.archive_file.init_get_items.output_base64sha256
  role             = var.lambda_iam_role
}