resource "aws_s3_bucket" "static_content" {
  bucket        = "${var.organization}-${var.environment}-${var.bucket_basename}-${var.service_name}"
  force_destroy = true

  tags = {
    Name        = "${var.organization}-${var.environment}-${var.bucket_basename}-${var.service_name}"
    Environment = var.environment
    Temp        = "false"
    Terraform   = "true"
  }
}

resource "aws_s3_bucket_public_access_block" "static_content" {
  bucket                  = aws_s3_bucket.static_content.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_cloudfront_origin_access_identity" "static_content_accesser" {}

resource "aws_s3_bucket_policy" "static_content" {
  bucket = aws_s3_bucket.static_content.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "CloudFrontAllow"
        Effect    = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.static_content_accesser.iam_arn
        }
        Action = [
          "s3:ListBucket",
          "s3:GetObject"
        ]
        Resource = [
          aws_s3_bucket.static_content.arn,
          "${aws_s3_bucket.static_content.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_cloudfront_distribution" "cdn" {
  enabled                  = true
  wait_for_deployment      = false
  aliases                  = var.cloudfront_distro_alternate_dns_aliases
  comment                  = "Distribution of frontend static content for ${var.environment}'s ${var.service_name}."
  is_ipv6_enabled          = true
  default_root_object      = var.cloudfront_default_root_object

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = var.cloudfront_minimum_protocol_version
  }

  origin {
    origin_id   = "frontend_static_content"
    domain_name = aws_s3_bucket.static_content.bucket_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static_content_accesser.cloudfront_access_identity_path
    }

    dynamic "custom_header" {
      for_each = var.cloudfront_origin_custom_headers
      content {
        name  = custom_header.value["name"]
        value = custom_header.value["value"]
      }
    }

  }

  default_cache_behavior {
    target_origin_id       = "frontend_static_content"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "allow-all"
    cache_policy_id        = "4135ea2d-6df8-44a3-9df3-4b5a84be39ad"
  }

  tags = {
    Name        = "${var.organization}-${var.environment}-${var.bucket_basename}-${var.service_name}"
    Environment = var.environment
    Temp        = "false"
    Terraform   = "true"
  }
}

data "aws_route53_zone" "current" {
  name = var.route53_hosted_zone
}

resource "aws_route53_record" "static_content" {
  count = length(var.route53_dns_records)

  zone_id = data.aws_route53_zone.current.zone_id
  name    = var.route53_dns_records[count.index]
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = true
  }
}
