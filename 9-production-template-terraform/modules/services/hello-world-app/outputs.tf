output "dns_name" {
    value = module.alb.dns_name
    description = "App load balancer domain name"
}

output "asg_name" {
    value = module.asg.asg_name
    description = "The name of the ASG"
}

output "instance_security_group_id" {
    value = module.asg.instance_security_group_id
    description = "The id of the EC2 Instance Security Group"
}