resource "aws_route53_zone" "yellow" {
  name = "yellow.rauten.co.za"
}

resource "aws_route53_record" "app" {
  zone_id = aws_route53_zone.yellow.id
  name    = "app.${aws_route53_zone.yellow.name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_alb.node_ingress.dns_name]
}

resource "aws_route53_record" "telco" {
  zone_id = aws_route53_zone.yellow.id
  name    = "telco.${aws_route53_zone.yellow.name}"
  type    = "CNAME"
  ttl     = 300
  records = [aws_alb.telco_ingress.dns_name]
}

# Certs
resource "aws_acm_certificate" "yellow" {
  domain_name = aws_route53_zone.yellow.name
  subject_alternative_names = [
    aws_route53_record.telco.name,
    aws_route53_record.app.name
  ]
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for dvo in aws_acm_certificate.yellow.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.yellow.id
}
resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.yellow.arn
  validation_record_fqdns = [for record in aws_route53_record.validation : record.fqdn]
}
