data "archive_file" "init" {
  type        = "zip"
  source_file = "${dirname(path.cwd)}/${each.value.file_path}"
  output_path = "${dirname(path.cwd)}/outputs/${each.value.file_path}.zip"
  for_each = var.lambdas
}

resource "aws_lambda_function" "deploy" {
  function_name    = each.key
  handler          = "${split(".", basename(each.value.file_path))[0]}.handler"
  runtime          = each.value.runtime
  filename         = data.archive_file.init[each.key].output_path
  source_code_hash = data.archive_file.init[each.key].output_base64sha256
  role             = var.lambda_iam_role
  for_each = var.lambdas
}