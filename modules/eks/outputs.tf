output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "The name of the EKS cluster"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "Endpoint for EKS control plane"
}

output "cluster_certificate_authority_data" {
  value       = aws_eks_cluster.main.certificate_authority[0].data
  description = "Certificate authority data for cluster verification"
}

output "lb_controller_role_arn" {
  value = aws_iam_role.lb_controller.arn
}

output "nginx_lb_security_group_id" {
  value       = aws_security_group.nginx_lb_ingress.id
  description = "Security group ID for the nginx-demo NLB ingress"
}
