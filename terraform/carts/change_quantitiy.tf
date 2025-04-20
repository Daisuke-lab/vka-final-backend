variable change_quantity_filename {
  default = "change_quantity"
}

data "archive_file" "init_change_quantity" {
  type        = "zip"
  source_file = "${dirname(path.cwd)}/carts/${var.change_quantity_filename}.mjs"
  output_path = "${dirname(path.cwd)}/outputs/${var.change_quantity_filename}.zip"

}

resource "aws_lambda_function" "change_quantity" {
  function_name    = "vka-cart-change-quantity"
  handler          = "${var.change_quantity_filename}.handler"
  runtime          = "nodejs22.x"
  filename         = data.archive_file.init_change_quantity.output_path
  source_code_hash = data.archive_file.init_change_quantity.output_base64sha256
  role             = var.lambda_iam_role
}