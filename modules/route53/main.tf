resource "aws_route53_zone" "protected" {
  # if allow_destroy_hosted_zone = false
  count = var.allow_destroy_hosted_zone ? 0 : 1

  name = var.domain_name
  comment = "Hosted zone for chatbot"

  lifecycle {
  prevent_destroy = true
  }


  tags = {
    Project     = var.project_tag
    Environment = var.environment
  }
}

resource "aws_route53_zone" "unprotected" {
  # if allow_destroy_hosted_zone = true
  count = var.allow_destroy_hosted_zone ? 1 : 0

  name = var.domain_name
  comment = "Hosted zone for chatbot"

  lifecycle {
  prevent_destroy = false
  }


  tags = {
    Project     = var.project_tag
    Environment = var.environment
  }
}

resource "aws_route53_record" "app_dns" {
  zone_id = (
    var.allow_destroy_hosted_zone
    ? aws_route53_zone.unprotected[0].zone_id
    : aws_route53_zone.protected[0].zone_id
  )
  name    = "${var.subdomain_name}.${var.domain_name}"
  type    = "CNAME"
  ttl     = 300
  records = [var.alb_dns_name]
}