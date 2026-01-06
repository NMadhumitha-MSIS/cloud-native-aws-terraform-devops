# Create cert ONLY if using the "dev" profile
resource "aws_acm_certificate" "dev_cert" {
  count             = var.profile == "dev" ? 1 : 0
  domain_name       = "dev.madhucsye.me"
  validation_method = "DNS"

  tags = {
    Environment = "dev"
    Name        = "dev-ssl-cert"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create Route 53 validation records ONLY for dev
resource "aws_route53_record" "dev_cert_validation" {
  for_each = var.profile == "dev" ? {
    for dvo in aws_acm_certificate.dev_cert[0].domain_validation_options :
    dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      record = dvo.resource_record_value
    }
  } : {}

  name    = each.value.name
  type    = each.value.type
  zone_id = data.aws_route53_zone.dev[0].zone_id
  records = [each.value.record]
  ttl     = 60
}

# Validate dev cert ONLY if dev profile
resource "aws_acm_certificate_validation" "dev_cert_validation_complete" {
  count = var.profile == "dev" ? 1 : 0

  certificate_arn         = aws_acm_certificate.dev_cert[0].arn
  validation_record_fqdns = [for record in aws_route53_record.dev_cert_validation : record.fqdn]
}
