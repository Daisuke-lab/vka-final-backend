variable add_item_filename {
  default = "add_item"
}

data "archive_file" "init_add_item" {
  type        = "zip"
  source_file = "${dirname(path.cwd)}/carts/${var.add_item_filename}.mjs"
  output_path = "${dirname(path.cwd)}/outputs/${var.add_item_filename}.zip"

}

resource "aws_lambda_function" "add_item" {
  function_name    = "vka-cart-add-item"
  handler          = "${var.add_item_filename}.handler"
  runtime          = "nodejs22.x"
  filename         = data.archive_file.init_add_item.output_path
  source_code_hash = data.archive_file.init_add_item.output_base64sha256
  role             = var.lambda_iam_role
}