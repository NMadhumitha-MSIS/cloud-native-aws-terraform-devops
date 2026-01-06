# Application Load Balancer
resource "aws_lb" "webapp_alb" {
  name               = "csye6225-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    aws_subnet.public_subnets[0].id,
    aws_subnet.public_subnets[1].id
  ]
  enable_deletion_protection = false
  tags = {
    Name = "webapp-alb"
  }
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Allow HTTP/HTTPS traffic"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "ALB Security Group"
  }
}

# Target Group
resource "aws_lb_target_group" "webapp_tg" {
  name     = "csye6225-tg-${substr(random_uuid.bucket_suffix.result, 0, 8)}"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.custom_vpc.id

  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

#resource "aws_lb_listener" "webapp_https_listener" {
#load_balancer_arn = aws_lb.webapp_alb.arn
#port              = 443
#protocol          = "HTTPS"
#ssl_policy        = "ELBSecurityPolicy-2016-08"
#certificate_arn   = aws_acm_certificate_validation.dev_cert_validation_complete.certificate_arn

#default_action {
#type             = "forward"
#target_group_arn = aws_lb_target_group.webapp_tg.arn
#}
#}

resource "aws_lb_listener" "demo_https_listener" {
  load_balancer_arn = aws_lb.webapp_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_cert_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webapp_tg.arn
  }
}
