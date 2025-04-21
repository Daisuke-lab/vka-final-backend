resource "aws_cloudfront_distribution" "frontned_cache" {
    origin {
        domain_name              = aws_s3_bucket.frontend.website_endpoint
        origin_id                = aws_s3_bucket.frontend.id
        custom_origin_config {
              http_port                = 80
              https_port               = 443
              origin_keepalive_timeout = 5
              origin_protocol_policy   = "http-only"
              origin_read_timeout      = 30
              origin_ssl_protocols     = [
                  "SSLv3",
                  "TLSv1",
                  "TLSv1.1",
                  "TLSv1.2",
                ]
            }
    }

    
    viewer_certificate {
        cloudfront_default_certificate = true
    }
    default_cache_behavior {
      allowed_methods        = ["GET", "HEAD"]
        cached_methods         = ["GET", "HEAD"]
        target_origin_id = aws_s3_bucket.frontend.id
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
        locations = []
        restriction_type = "none"
      }
    }

    custom_error_response {
    error_code         = 403
    response_page_path = "/index.html"
    response_code      = 200
    error_caching_min_ttl = 10 
  }
  
}