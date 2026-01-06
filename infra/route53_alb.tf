data "aws_route53_zone" "dev" {
  count        = var.profile == "dev" ? 1 : 0
  name         = "dev.madhucsye.me"
  private_zone = false
}

resource "aws_route53_record" "dev_alias" {
  count   = var.profile == "dev" ? 1 : 0
  zone_id = data.aws_route53_zone.dev[0].zone_id
  name    = "dev.madhucsye.me"
  type    = "A"

  alias {
    name                   = aws_lb.webapp_alb.dns_name
    zone_id                = aws_lb.webapp_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "demo_alias" {
  zone_id = data.aws_route53_zone.demo.zone_id
  name    = "demo.madhucsye.me"
  type    = "A"

  alias {
    name                   = aws_lb.webapp_alb.dns_name
    zone_id                = aws_lb.webapp_alb.zone_id
    evaluate_target_health = true
  }
}

data "aws_route53_zone" "demo" {
  name         = "demo.madhucsye.me"
  private_zone = false
}