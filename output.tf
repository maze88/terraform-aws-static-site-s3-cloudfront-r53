output "service_name" {
  value = var.service_name
}

output "s3_bucket_id" {
  value = aws_s3_bucket.static_content.id
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.cdn.id
}

output "route53_fqdn_list" {
  value = aws_route53_record.static_content[*].fqdn
}
