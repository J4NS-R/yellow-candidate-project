resource "aws_route53_zone" "yellow" {
  name = "yellow.rauten.co.za"
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.yellow.id
  name    = aws_route53_zone.yellow.name
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
  domain_name               = aws_route53_zone.yellow.name
  subject_alternative_names = [aws_route53_record.telco.name]
  validation_method         = "DNS"

  validation_option {
    domain_name       = aws_route53_zone.yellow.name
    validation_domain = aws_route53_zone.yellow.name
  }
  lifecycle {
    create_before_destroy = true
  }
}
