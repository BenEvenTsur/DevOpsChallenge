output "alb_url" {
  description = "ALB public URL"
  value       = "http://${aws_alb.alb.dns_name}"
}