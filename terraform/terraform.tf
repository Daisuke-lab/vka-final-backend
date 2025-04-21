terraform {
  backend "s3" {
    bucket = "vka-terraform-tfstate"
    region = "us-east-2"
    key    = "terraform.tfstate"
  }
}