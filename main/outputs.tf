output "acm_manual_dns_records" {
  value = module.acm.acm_dns_records_to_add
}

output "name_servers" {
  description = "NS records to add to your DNS registrar"
  value       = module.route53.name_servers
}
