# Monitoring Ingress Module - outputs.tf

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "grafana_url" {
  description = "The URL for the Grafana dashboard."
  value       = "https://${var.grafana_domain_name}"
}
