output "zone_id" {
  description = "Route53 Hosted Zone ID"
  value = (
    var.allow_destroy_hosted_zone
    ? aws_route53_zone.unprotected[0].zone_id
    : aws_route53_zone.protected[0].zone_id
  )
}

output "name_servers" {
  description = "NS records to configure at domain registrar"
  value = (
    var.allow_destroy_hosted_zone
    ? aws_route53_zone.unprotected[0].name_servers
    : aws_route53_zone.protected[0].name_servers
  )
}