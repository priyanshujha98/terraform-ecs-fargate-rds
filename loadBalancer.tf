resource "aws_lb" "backend_load_balancer" {

  name               = "${var.infra_env}-backend-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_security_group.id]
  subnets            = [for subnet in aws_subnet.public : subnet.id]

  tags = {
    "Infra" = "${var.infra_env}"
    Name    = "${var.infra_env}-backend-load-balancer"
  }

}

resource "aws_lb_target_group" "backend_load_balancer_target_group" {
  name                 = "${var.infra_env}-backend-loadbalancer-tg"
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = aws_vpc.demo_admin.id
  deregistration_delay = 180
  health_check {
    path                = "/test"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 2
    interval            = 5
    matcher             = "200" # has to be HTTP 200 or fails
  }

  tags = {
    "Infra" = "${var.infra_env}"
    Name    = "${var.infra_env}-backend-loadbalancer-tg"
  }
}

resource "aws_lb_listener" "backend_loadbalancer_listner_https" {
  load_balancer_arn = aws_lb.backend_load_balancer.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.loadblancer_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_load_balancer_target_group.arn
  }
}

resource "aws_lb_listener" "backend_loadbalancer_listner_http" {
  load_balancer_arn = aws_lb.backend_load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_302"
    }
  }
}
