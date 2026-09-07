resource "aws_autoscaling_group" "app" {
  name_prefix         = "${local.prefix_name}-asg-"
  vpc_zone_identifier = var.private_subnet_ids

  min_size         = local.min_size
  max_size         = local.max_size
  desired_capacity = local.desired_capacity

  target_group_arns = var.target_group_arns

  launch_template {
    id      = aws_launch_template.app.id
    version = "$Latest"
  }

  force_delete = true

  health_check_type         = "ELB"
  health_check_grace_period = 300

  dynamic "tag" {
    for_each = {
      Name        = "${local.prefix_name}-app-instance"
      Environment = var.env_name
      ManagedBy   = "Terraform"
      Role        = var.role
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity] # Allows external auto-scalers/policies to manage capacity without state drift
  }
}

resource "aws_autoscaling_policy" "cpu_target_tracking" {
  name                   = "${local.prefix_name}-cpu-target-tracking"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.app.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}
