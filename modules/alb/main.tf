resource "aws_security_group" "alb" {
  name        = "${var.env_name}-alb-sg"
  description = "Controls inbound traffic to the Application Load Balancer"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.env_name}-alb-sg"
  }
}

resource "aws_security_group_rule" "alb_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTP from Internet"
}

resource "aws_security_group_rule" "alb_ingress_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow HTTPS from Internet"
}

resource "aws_security_group_rule" "alb_egress_all" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.alb.id
  description       = "Allow all outbound traffic"
}

resource "aws_lb" "app" {
  name               = "${var.env_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name        = "${var.env_name}-alb"
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb_target_group" "al2023" {
  name        = "${var.env_name}-al2023-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  # Fast deregistration on destroy (default is 300)
  deregistration_delay = 10

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200,301"
  }

  tags = {
    Name        = "${var.env_name}-al2023-tg"
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb_target_group" "ubuntu" {
  name        = "${var.env_name}-ubuntu-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  # Fast deregistration on destroy (default is 300)
  deregistration_delay = 10

  health_check {
    enabled             = true
    path                = "/health"
    protocol            = "HTTP"
    port                = "traffic-port"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
    matcher             = "200,301"
  }

  tags = {
    Name        = "${var.env_name}-ubuntu-tg"
    Environment = var.env_name
    ManagedBy   = "Terraform"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.al2023.arn
        weight = 50
      }
      target_group {
        arn    = aws_lb_target_group.ubuntu.arn
        weight = 50
      }
    }
  }
}
