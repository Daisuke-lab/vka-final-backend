variable remove_item_filename {
  default = "remove_item"
}

data "archive_file" "init_remove_item" {
  type        = "zip"
  source_file = "${dirname(path.cwd)}/carts/${var.remove_item_filename}.mjs"
  output_path = "${dirname(path.cwd)}/outputs/${var.remove_item_filename}.zip"

}

resource "aws_lambda_function" "remove_item" {
  function_name    = "vka-cart-remove-item"
  handler          = "${var.remove_item_filename}.handler"
  runtime          = "nodejs22.x"
  filename         = data.archive_file.init_remove_item.output_path
  source_code_hash = data.archive_file.init_remove_item.output_base64sha256
  role             = var.lambda_iam_role
}