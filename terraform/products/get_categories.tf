variable categories_filename {
  default = "get_categories"
}

resource "null_resource" "hash_categories_file" {
  provisioner "local-exec" {
    command = "sha256sum ${dirname(path.cwd)}/products/${var.categories_filename}.py | awk '{print $1}' > hash_${var.categories_filename}.txt"
  }
  triggers = {
    always_run = timestamp()
  }
}
data "local_file" "hash_categories_file" {
  filename = "hash_${var.categories_filename}.txt"
  depends_on = [null_resource.hash_categories_file]
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
  source_code_hash = data.local_file.hash_categories_file.content_base64
  role             = var.lambda_iam_role
}