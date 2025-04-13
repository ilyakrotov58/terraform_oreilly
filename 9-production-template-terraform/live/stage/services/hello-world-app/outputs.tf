output "dns_name" {
    value = module.hello_world_app.dns_name
    description = "Load balancer domain name"
}