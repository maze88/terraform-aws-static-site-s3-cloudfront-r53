provider "aws" {
  region = "us-east-1"
}

module "static_site_infra" {
  source = "../"

  organization        = "acme"
  environment         = "staging"
  service_name        = "web-ui"
  route53_hosted_zone = "acme.xyz."
  route53_dns_records = [
    "*"
  ]
  acm_certificate_arn = "arn:aws:acm:us-east-1:123456789000:certificate/abcdef00-1234-abcd-5678-abcdef987654"
  cloudfront_distro_alternate_dns_aliases = [
    "ui.acme.xyz",
    "beta.acme.xyz"
  ]
  cloudfront_origin_custom_headers = [
    {name = "Referrer-Policy",        value = "strict-origin-when-cross-origin"},
    {name = "X-Content-Type-Options", value = "nosniff"},
    {name = "X-Frame-Options",        value = "SAMEORIGIN"},
    {name = "X-XSS-Protection",       value = "1"}
  ]
  cloudfront_default_root_object = "index.html"
}
