output "asg_id" {
  description = "The ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.id
}

output "asg_name" {
  description = "The name of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "asg_arn" {
  description = "The ARN of the Auto Scaling Group"
  value       = aws_autoscaling_group.app.arn
}

output "launch_template_id" {
  description = "The ID of the Launch Template"
  value       = aws_launch_template.app.id
}

output "launch_template_latest_version" {
  description = "The latest version of the Launch Template"
  value       = aws_launch_template.app.latest_version
}

output "app_security_group_id" {
  description = "The ID of the Security Group for the Application Servers"
  value       = aws_security_group.app.id
}

output "key_pair_name" {
  description = "The name of the SSH key pair"
  value       = aws_key_pair.app.key_name
}

output "capacity" {
  description = "The value of desired_capacity-max_size_min_size"
  value       = "${local.desired_capacity}-${local.max_size}-${local.min_size}"
}

output "iam_role_name" {
  description = "The name of the IAM role attached to EC2 instances"
  value       = aws_iam_role.app_role.name
}
