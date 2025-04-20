variable create_order_filename {
  default = "create_order"
}

data "archive_file" "init_create_order" {
  type        = "zip"
  source_file = "${dirname(path.cwd)}/orders/${var.create_order_filename}.mjs"
  output_path = "${dirname(path.cwd)}/outputs/${var.create_order_filename}.zip"

}

resource "aws_lambda_function" "create_order" {
  function_name    = "vka-order-create"
  handler          = "${var.create_order_filename}.handler"
  runtime          = "nodejs22.x"
  filename         = data.archive_file.init_create_order.output_path
  source_code_hash = data.archive_file.init_create_order.output_base64sha256
  role             = var.lambda_iam_role
}