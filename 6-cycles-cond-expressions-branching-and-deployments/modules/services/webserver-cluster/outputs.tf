output "alb_dns_name" {
    value = aws_lb.example.dns_name
    description = "App load balancer domain name"
}

output "asg_name" {
    value = aws_autoscaling_group.example.name
    description = "The name of the ASG"
}

output "alb_security_group_id" {
    value = aws_security_group.alb.id
    description = "The id of the Security group attached to the load balancer"
}