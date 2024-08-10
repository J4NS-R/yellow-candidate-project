output "alb_hostname" {
  value = aws_alb.node_ingress.dns_name
}
output "telco_hostname" {
  value = aws_alb.telco_ingress.dns_name
}
