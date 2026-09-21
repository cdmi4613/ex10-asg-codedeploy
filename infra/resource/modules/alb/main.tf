# ==========================================
# 1. Application Load Balancer
# ==========================================

resource "aws_lb" "app_alb" {
  name               = "${var.tag_header}alb"
  internal           = false
  load_balancer_type = "application"

  security_groups = [
    var.alb_security_group_id
  ]

  subnets = var.public_subnet_ids

  tags = {
    Name = "${var.tag_header}alb"
  }
}


# ==========================================
# 2. Target Group
# ==========================================

resource "aws_lb_target_group" "app_tg" {
  name        = "${var.tag_header}tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled  = true
    path     = "/"
    protocol = "HTTP"
    port     = "traffic-port"

    healthy_threshold   = 2
    unhealthy_threshold = 2

    timeout  = 5
    interval = 30

    matcher = "200-399"
  }

  tags = {
    Name = "${var.tag_header}tg"
  }
}


# ==========================================
# 3. HTTP Listener
# ==========================================

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.app_alb.arn

  port     = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}
