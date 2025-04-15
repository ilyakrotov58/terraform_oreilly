output "dns_name" {
  value       = module.hello_world_app.dns_name
  description = "The domain name of the load balancer"
}