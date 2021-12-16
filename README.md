# Terraform module: Infrastructure for S3 static site, with CloudFront distribution, Route53 DNS and ACM certificate
This module provisions infrastructure for hosting static web content (content _not_ included!).

### Prerequisites
- An existing Route53 hosted zone.
- A matching Route53 domain.

### Postrequisites
- Your site's static content and a suitable method to upload it the S3 bucket.
