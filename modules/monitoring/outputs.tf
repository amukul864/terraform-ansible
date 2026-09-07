output "sns_topic_arn" {
  value       = aws_sns_topic.asg_alerts.arn
  description = "ARN of the SNS topic created for alerts"
}

output "alarm_arns" {
  value       = { for k, v in aws_cloudwatch_metric_alarm.asg_cpu_high_alert : k => v.arn }
  description = "ARNs of the created CloudWatch alarms"
}
