resource "aws_route53_zone" "yellow" {
  name = "yellow.rauten.co.za"
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.yellow.id
  name    = aws_route53_zone.yellow.name
  type    = "A"
  ttl     = 300
  records = aws_eip.node_ingress_alb.*.public_ip
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

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "validation" {
  for_each = {
    for index, val in aws_acm_certificate.yellow.domain_validation_options :
    val.resource_record_name => val
  }
  zone_id = aws_route53_zone.yellow.id
  name    = each.value.resource_record_name
  type    = each.value.resource_record_type
  records = [each.value.resource_record_value]
  ttl     = 60
}
resource "aws_acm_certificate_validation" "validation" {
  certificate_arn         = aws_acm_certificate.yellow.arn
  validation_record_fqdns = aws_route53_record.validation.*.fqdn
}
