output "dns_name" {
  value       = module.alb.dns_name
  description = "The domain name of the load balancer"
}