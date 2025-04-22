resource "aws_s3_bucket" "frontend" {
  bucket = "vka-frontend"
}

resource "aws_s3_bucket" "images" {
  bucket = "vka-images"
}


resource "aws_s3_bucket" "artifact_store" {
  bucket = "codepipeline-us-east-2-12d7eee7160c-4590-8d45-1f7cb9daf857"
}