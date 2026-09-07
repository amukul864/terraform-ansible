resource "aws_security_group" "nginx_lb_ingress" {
  name        = "${var.environment}-nginx-demo-lb-ingress"
  description = "Explicit internet ingress for nginx-demo NLB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-nginx-demo-lb-ingress"
  }
}

resource "aws_security_group_rule" "allow_custom_lb_to_nodes" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nginx_lb_ingress.id
  security_group_id        = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  description              = "Allow nginx-demo LB security group to reach nodes on port 80"
}
