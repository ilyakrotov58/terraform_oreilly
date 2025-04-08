# Resource for creating an Auto Scaling Group (ASG) in AWS.
# This group automatically manages the scaling of EC2 instances
# based on the defined parameters
resource "aws_autoscaling_group" "example" {
    vpc_zone_identifier = data.aws_subnets.default.ids

    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"

    min_size = var.min_size
    max_size = var.max_size

    launch_template {
        id = aws_launch_template.example.id
    }

    tag {
        key = "Name"
        value = "${var.cluster_name}-asg"
        propagate_at_launch = true
    }

    # Here we added custom tags for ASG by for_each
    dynamic "tag" {
        for_each = var.custom_tags

        content {
            key = tag.key
            value = tag.value
            propagate_at_launch = true
        }
    }
}

# Planned increasing of asg capacity from 9 am every day
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {

    # It is like "if" statement for this resource
    # By variable we can create it or not at different enviroments
    count = var.enable_autoscaling ? 1 : 0

    scheduled_action_name = "scale_out_during_business_hours"
    min_size = 2
    max_size = 5
    desired_capacity = 5
    recurrence = "0 9 * * *"

    autoscaling_group_name = aws_autoscaling_group.example.name
}

# Planned decreasing of asg capacity from 5 pm every day
resource "aws_autoscaling_schedule" "scale_in_at_night" {
    
    # It is like "if" statement for this resource
    # By variable we can create it or not at different enviroments
    count = var.enable_autoscaling ? 1 : 0
    
    scheduled_action_name = "scale_in_at_night"
    min_size = 2
    max_size = 5
    desired_capacity = 2
    recurrence = "0 17 * * *"

    autoscaling_group_name = aws_autoscaling_group.example.name
}

# Launch templates define configuration details for EC2 instances,
# including AMI, instance type, security groups, and startup scripts
resource "aws_launch_template" "example" {
    image_id = "ami-0fb653ca2d3203ac1"
    instance_type = var.instance_type
    vpc_security_group_ids = [aws_security_group.instance.id]

    user_data = base64encode(templatefile("${path.module}/user-data.sh",
    {
        server_port = var.server_port
        db_adress = data.terraform_remote_state.db.outputs.adress
        db_port = data.terraform_remote_state.db.outputs.port
    }))

    # Ensures a new launch configuration is created before the old one is destroyed, 
    # since ASG keep a reference to the existing configuration
    lifecycle {
        create_before_destroy = true
    }
}

# ALBs distribute incoming HTTP(S) traffic across multiple targets,
# such as EC2 instances in an Auto Scaling Group
resource "aws_lb" "example" {
    name = "${var.cluster_name}-alb"
    load_balancer_type = "application"
    subnets = data.aws_subnets.default.ids
    security_groups = [aws_security_group.alb.id]
}

# Listeners check for incoming traffic on a specified port and protocol,
# and define actions to take based on the request
resource "aws_lb_listener" "http" {

    # ARN is a unique identifier for a resource in AWS, 
    # used to refer to the resource accurately in different contexts
    load_balancer_arn = aws_lb.example.arn
    port = local.http_port
    protocol = "HTTP"

    default_action {
      type = "fixed-response"

      fixed_response {
        content_type = "text/plain"
        message_body = "404: page not found"
        status_code = 404
      }
    }
}

# Target groups are used to route traffic to a group of targets, such as EC2 instances
# They also manage health checks to ensure that traffic is only sent to healthy targets
resource "aws_lb_target_group" "asg" {
    name = var.aws_lb_target_group_name
    port = var.server_port
    protocol = "HTTP"
    vpc_id = data.aws_vpc.default.id

    health_check {
        path = "/"
        protocol = "HTTP"
        matcher = "200"
        interval = 15
        timeout = 3
        healthy_threshold = 2
        unhealthy_threshold = 2
    }
}

# Listener rules define actions based on request conditions such as path patterns
# When a request matches the condition, the defined action is performed
resource "aws_lb_listener_rule" "asg" {
    listener_arn =  aws_lb_listener.http.arn
    priority = 100

    condition {
        path_pattern {
            values = ["/*"]
        }
    } 
    
    action {
        type = "forward"
        target_group_arn = aws_lb_target_group.asg.arn
    }
}

resource "aws_security_group" "instance" {
    name = "${var.cluster_name}-instance"

    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = local.tcp_protocol
        cidr_blocks = local.all_ips
    }
}

# Resource for creating a security group for the Application Load Balancer (ALB)
# A security group acts as a virtual firewall to control inbound and outbound traffic to/from resources
resource "aws_security_group" "alb" {
    name = "${var.cluster_name}-alb"
}

# This is same as ingress from aws_security_group_alb, but as separated resource
# Enable all incoming requests
resource "aws_security_group_rule" "allow_http_inbound" {
    type = "ingress"
    security_group_id = aws_security_group.alb.id

    from_port = local.http_port
    to_port = local.http_port
    protocol = local.tcp_protocol
    cidr_blocks = local.all_ips
}

# This is same as egress from aws_security_group_alb, but as separated resource
# Enable all outcoming responses
resource "aws_security_group_rule" "allow_all_outbound" {
    type = "egress"
    security_group_id = aws_security_group.alb.id

    from_port = local.any_port
    to_port = local.any_port
    protocol = local.any_protocol
    cidr_blocks = local.all_ips
}

# Reading state of the db from the bucket
data "terraform_remote_state" "db" {
    backend = "s3"

    config = {
        bucket = var.db_remote_state_bucket
        key = var.db_remote_state_key
        region = "us-east-2"
    }
}

data "aws_vpc" "default" {
    default = true
}

data "aws_subnets" "default" {
    filter {
        name = "vpc-id"
        values = [data.aws_vpc.default.id]
    }
}

locals {
    http_port = 80
    any_port = 0
    any_protocol = "-1"
    tcp_protocol = "tcp"
    all_ips = ["0.0.0.0/0"]
}