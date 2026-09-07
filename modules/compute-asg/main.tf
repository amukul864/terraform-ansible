resource "aws_security_group" "app" {
  name        = "${local.prefix_name}-sg"
  description = "Security group for ${local.prefix_name} instances"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${local.prefix_name}-sg"
  }
}

resource "aws_security_group_rule" "app_ingress_alb_http" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = var.alb_security_group_id
  description              = "Allow HTTP from ALB only"
}

resource "aws_security_group_rule" "app_ingress_alb_https" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.app.id
  source_security_group_id = var.alb_security_group_id
  description              = "Allow HTTPS from ALB only"
}

resource "aws_security_group_rule" "allow_bastion_ssh" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = var.bastion_security_group_id
  security_group_id        = aws_security_group.app.id
}

resource "aws_security_group_rule" "app_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.app.id
  description       = "Allow all outbound traffic"
}

resource "aws_iam_role" "app_role" {
  name = "${local.prefix_name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "app_profile" {
  name = "${local.prefix_name}-instance-profile"
  role = aws_iam_role.app_role.name
}
