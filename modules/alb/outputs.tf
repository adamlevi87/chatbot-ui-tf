output "alb_dns_name" {
  description = "The DNS name of the ALB, used to access the service externally"
  value       = aws_lb.this.dns_name
}

output "target_group_arn" {
  description = "ARN of the ALB target group for ECS service registration"
  value       = aws_lb_target_group.this.arn
}

output "https_listener_arn" {
  description = "ARN of the HTTPS listener for the ALB"
  value       = aws_lb_listener.https.arn
}