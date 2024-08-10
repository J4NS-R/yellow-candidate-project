output "alb_hostname" {
  value = aws_alb.node_ingress.dns_name
}
