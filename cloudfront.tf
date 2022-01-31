locals {
  originDomain = "${var.infra_env}_demo_admin_frontend.s3.${var.region}.amazonaws.com"
}

resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin Access identity for ${local.originDomain}"
}


resource "aws_cloudfront_distribution" "demo_cloudfront_distribution" {
    origin{
        domain_name = aws_s3_bucket.demo_s3_bucket.bucket_domain_name
        origin_id = local.originDomain

        s3_origin_config {
          origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
        }
    }

    enabled = true
    is_ipv6_enabled = true
    comment = "Cloud front distribution for ${var.infra_env}"
    default_root_object = "index.html"

    aliases = [var.infra_env == "prod" ? "admin.demo.com" : var.infra_env == "dev" ? "dev-admin.demo.com" : "qa-admin.demo.com"]

    default_cache_behavior {
      allowed_methods = [ "HEAD" ,"DELETE","GET", "POST", "PUT", "PATCH", "OPTIONS"]
      cached_methods = ["GET", "HEAD"]
      target_origin_id = local.originDomain
      viewer_protocol_policy  = "redirect-to-https"

      forwarded_values {
        query_string = false
        cookies {
            forward = "none"
        }
      }
    }

    price_class = "PriceClass_200"

    restrictions {
        geo_restriction {
          restriction_type = "none"
        }
    }

    viewer_certificate {
        acm_certificate_arn = var.loadblancer_certificate_arn
        cloudfront_default_certificate = true
        ssl_support_method = "sni-only"
    }



    tags = {
      "Name" = "${var.infra_env}-cloudfront-distribution",
      "Env" = "${var.infra_env}"
    }

    custom_error_response {
      error_code = 403
      error_caching_min_ttl = 10
      response_code = 200
      response_page_path = "/index.html"
    }
  
}