variable "region" {
  description = "The region in which the resources are provisioned."
  type        = string
}

variable "organization" {
  description = "The organization/company name. Used as a prefix for resources that need globally unique names such as S3 buckets."
  type        = string
}

variable "environment" {
  description = "The name of the environment being provisioned. Used in resources names and tags."
  type        = string
}

variable "service_name" {
  description = "The frontend service name."
  type        = string

  validation {
    condition = var.service_name == lower(var.service_name)
    error_message = "The frontend service name must be lowercase."
  }
}

variable "bucket_basename" {
  description = "The bucket basename is used along with organization, environment and service names when naming the S3 bucket."
  type        = string
  default     = "fe-static-content"

  validation {
    condition = var.bucket_basename == lower(var.bucket_basename)
    error_message = "The bucket basename must be lowercase."
  }
}

variable "route53_hosted_zone" {
  description = "Route53 DNS hosted zone name. Example: 'foobar.com.' (note the '.' at the end)."
  type        = string
}

variable "route53_dns_records" {
  description = "A list containing DNS names (A) to route via alias to the CloudFront Distribution."
  type        = list(string)

  validation {
    condition = alltrue([
      for record in var.route53_dns_records : record == lower(record)
    ])
    error_message = "Route53 DNS records must be lowercase."
  }
}

variable "acm_certificate_arn" {
  description = "The ARN of an existing certificate to use for the frontend services."
  type        = string
}

variable "cloudfront_distro_alternate_dns_aliases" {
  description = "A list containing extra CNAMEs (alternate domain names), if any, to associate with the CloudFront distribution."
  type        = list(string)

  validation {
    condition = alltrue([
      for alias in var.cloudfront_distro_alternate_dns_aliases : alias == lower(alias)
    ])
    error_message = "Alternate CNAME record aliases must be lowercase."
  }
}

variable "cloudfront_minimum_protocol_version" {
  description = "A list containing extra CNAMEs (alternate domain names), if any, to associate with the CloudFront distribution."
  type        = string
  default     = "TLSv1.2_2021"

  validation {
    condition = contains(["SSLv3", "TLSv1", "TLSv1_2016", "TLSv1.1_2016", "TLSv1.2_2018", "TLSv1.2_2019", "TLSv1.2_2021"], var.cloudfront_minimum_protocol_version)
    error_message = "Security protocol must be one of the valid list (see variables.tf)."
  }
}

variable "cloudfront_origin_custom_headers" {
  description = "A list of objects with name & value for each custom header."
  type = list(object({
    name  = string
    value = string
  }))
}

variable "cloudfront_default_root_object" {
  description = "The object that you want CloudFront to return (for example, index.html) when an end user requests the root URL."
  type        = string
  default     = "index.html"
}
