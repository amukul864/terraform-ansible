resource "aws_launch_template" "app" {
  name_prefix   = "${local.prefix_name}-lt-"
  image_id      = var.ami_id
  instance_type = local.instance_type
  key_name      = aws_key_pair.app.key_name

  vpc_security_group_ids = [aws_security_group.app.id]

  user_data = base64encode(local.user_data_script)

  update_default_version = true

  iam_instance_profile {
    arn = aws_iam_instance_profile.app_profile.arn
  }

  monitoring {
    enabled = true
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${local.prefix_name}-app-node"
      Environment = var.env_name
      Role        = var.role
      ManagedBy   = "Terraform"
    }
  }

  lifecycle {
    create_before_destroy = true
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2
  }
}
