output "alb_security_group_id" {
  description = "The ID of the Security Group for the Application Load Balancer"
  value       = aws_security_group.alb.id
}

output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.app.dns_name
}

output "al2023_target_group_arn" {
  description = "ARN of the AL2023 Target Group"
  value       = aws_lb_target_group.al2023.arn
}

output "ubuntu_target_group_arn" {
  description = "ARN of the Ubuntu Target Group"
  value       = aws_lb_target_group.ubuntu.arn
}

output "alb_public_url" {
  description = "Public URL to access the application"
  value       = "http://${aws_lb.app.dns_name}"
}
