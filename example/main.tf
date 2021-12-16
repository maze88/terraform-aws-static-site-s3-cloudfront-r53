provider "aws" {
  region = "us-east-1"
}

module "static_site_infra" {
  source = "../"

  organization        = "foobar"
  environment         = "test"
  service_name        = "my-webapp"
  route53_hosted_zone = "foobar.xyz."
  route53_dns_records = [
    "*"
  ]
  cloudfront_distro_alternate_dns_aliases = [
    "www.foobar.xyz",
    "app.foobar.xyz"
  ]
  cloudfront_origin_custom_headers = [
    {name = "Referrer-Policy",        value = "strict-origin-when-cross-origin"},
    {name = "X-Content-Type-Options", value = "nosniff"},
    {name = "X-XSS-Protection",       value = "1"}
  ]
  cloudfront_default_root_object = "index.html"
}
