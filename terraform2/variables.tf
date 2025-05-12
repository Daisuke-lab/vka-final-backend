

variable "lambda_iam_role" {
  default = "arn:aws:iam::555399571935:role/service-role/vka-product-search-role-mxj7mb8t"
}

variable "lambdas2" {
  type = map(map(string))
  default = {
    mail-subscribe = {
      function_name = "vka-mail-subscribe"
      file_path     = "lambdas/mail_subcribe.py"
      runtime       = "python3.10"
    }
  } 
}

variable "post_authentication_lambda" {
  default = "arn:aws:lambda:us-east-2:555399571935:function:vka-mail-subscribe"
  type        = string
}

variable "cloudfront_domain" {
  default = "https://d1fguzyk3x4gyq.cloudfront.net"
  type        = string
}