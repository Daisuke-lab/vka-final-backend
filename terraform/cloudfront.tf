resource "aws_cloudfront_origin_access_control" "frontend_cache" {
  name                              = "vka-frontend.s3.us-east-2.amazonaws.com"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "frontend_cache" {
  default_root_object = "index.html"
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.frontend.id
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend_cache.id
    # custom_origin_config {
    #   http_port                = 80
    #   https_port               = 443
    #   origin_keepalive_timeout = 5
    #   origin_protocol_policy   = "http-only"
    #   origin_read_timeout      = 30
    #   origin_ssl_protocols = [
    #     "SSLv3",
    #     "TLSv1",
    #     "TLSv1.1",
    #     "TLSv1.2",
    #   ]
    # }
  }


  viewer_certificate {
    cloudfront_default_certificate = true
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.frontend.id
    viewer_protocol_policy = "allow-all"
    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }

    }
  }
  enabled = true
  restrictions {
    geo_restriction {
      locations        = []
      restriction_type = "none"
    }
  }

  custom_error_response {
    error_code            = 403
    response_page_path    = "/index.html"
    response_code         = 200
    error_caching_min_ttl = 10
  }

}