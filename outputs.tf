output "alb_dns_name" {
  value       = aws_lb.external_alb.dns_name
  description = "Dirección pública del Balanceador para ingresar al sistema (Usarla en mi test)"
}

