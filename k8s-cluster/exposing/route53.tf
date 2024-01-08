data "kubernetes_service" "prj_grpc" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
}

resource "aws_route53_record" "prj_grpc" {
  zone_id = var.project_route53_zone_id
  name    = "${var.project_name}-grpc.${var.project_route53_zone_name}"
  type    = "CNAME"
  ttl     = 300
  records = [data.kubernetes_service.prj_grpc.status.0.load_balancer.0.ingress.0.hostname]
}
