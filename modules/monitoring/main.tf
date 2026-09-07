resource "aws_sns_topic" "asg_alerts" {
  name = "${var.environment}-asg-high-cpu-alerts"
}

resource "aws_sns_topic_subscription" "email_sub" {
  topic_arn = aws_sns_topic.asg_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_metric_alarm" "asg_cpu_high_alert" {
  for_each = toset(var.asg_names)

  alarm_name          = "${var.environment}-${each.value}-high-cpu-alert-${var.cpu_threshold}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "Monitors high CPU utilization (>= ${var.cpu_threshold}%) on ASG ${each.value}"

  dimensions = {
    AutoScalingGroupName = each.value
  }

  alarm_actions = [aws_sns_topic.asg_alerts.arn]
  ok_actions    = [aws_sns_topic.asg_alerts.arn]
}
