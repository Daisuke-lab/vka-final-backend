resource "aws_dynamodb_table" "product_table" {
  name = "ProductTable"
  attribute {
    name = "category"
    type = "S"
  }

  attribute {
    name = "product_id"
    type = "N"
  }
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "category"
  range_key    = "product_id"
}

resource "aws_dynamodb_table" "user_table" {
  name = "UserTable"
  attribute {
    name = "user_id"
    type = "S"
  }

  attribute {
    name = "sort_id"
    type = "S"
  }
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "sort_id"
}