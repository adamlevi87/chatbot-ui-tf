resource "aws_lb" "this" {
  name               = "${var.project_tag}-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.public_subnet_ids
  security_groups    = [var.alb_security_group_id]

  tags = {
    Project     = var.project_tag
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "this" {
  name        = "${var.project_tag}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }

  tags = {
    Project     = var.project_tag
    Environment = var.environment
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_cert_arn

  depends_on = [
    var.acm_depends_on
  ]

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}