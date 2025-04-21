resource "aws_s3_bucket" "frontend" {
  bucket = "vka-frontend"
}

resource "aws_s3_bucket" "images" {
  bucket = "vka-images"
}

resource "aws_s3_bucket_website_configuration" "static" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "index.html"
  }
}