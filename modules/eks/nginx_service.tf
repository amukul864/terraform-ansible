resource "kubernetes_service" "nginx_demo_lb" {
  metadata {
    name      = "nginx-demo"
    namespace = "default"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"            = "external"
      "service.beta.kubernetes.io/aws-load-balancer-nlb-target-type" = "ip"
      "service.beta.kubernetes.io/aws-load-balancer-scheme"          = "internet-facing"
      "service.beta.kubernetes.io/aws-load-balancer-security-groups" = aws_security_group.nginx_lb_ingress.id
    }
  }
  spec {
    type = "LoadBalancer"
    selector = {
      app = "nginx-demo"
    }
    port {
      port        = 80
      target_port = 80
    }
  }

  depends_on = [
    helm_release.lb_controller
  ]
}
