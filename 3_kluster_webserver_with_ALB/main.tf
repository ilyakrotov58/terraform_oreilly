provider "aws" {
    region = "us-east-2"
}

# Bucket for saving state
# Located in 4_S3_bucket
terraform {
    backend "s3" {
        bucket = "terraform-s3-bucket-ilia-example"
        key = "global/s3/terraform.tfstate"
        region = "us-east-2"

        dynamodb_table = "terraform_s3_ilia_example-locks"
        encrypt = true
    }
}

# Resource for creating an Auto Scaling Group (ASG) in AWS.
# This group automatically manages the scaling of EC2 instances
# based on the defined parameters
resource "aws_autoscaling_group" "example" {
    vpc_zone_identifier = data.aws_subnets.default.ids

    target_group_arns = [aws_lb_target_group.asg.arn]
    health_check_type = "ELB"

    min_size = 2
    max_size = 5

    launch_template {
        id = aws_launch_template.example.id
    }

    tag {
        key = "Name"
        value = "terraform-asg-example"
        propagate_at_launch = true
    }
}

# Launch templates define configuration details for EC2 instances,
# including AMI, instance type, security groups, and startup scripts
resource "aws_launch_template" "example" {
    image_id = "ami-0fb653ca2d3203ac1"
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]

    user_data = base64encode(<<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
    )

    # Ensures a new launch configuration is created before the old one is destroyed, 
    # since ASG keep a reference to the existing configuration
    lifecycle {
        create_before_destroy = true
    }
}

# ALBs distribute incoming HTTP(S) traffic across multiple targets,
# such as EC2 instances in an Auto Scaling Group
resource "aws_lb" "example" {
    name = "terraform-asg-example"
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
    port = 80
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
    name = "terraform-asg-example"
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
    name = "terraform-example-instance"

    ingress {
        from_port   = var.server_port
        to_port     = var.server_port
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Resource for creating a security group for the Application Load Balancer (ALB)
# A security group acts as a virtual firewall to control inbound and outbound traffic to/from resources
resource "aws_security_group" "alb" {
    # Enable all incoming requests
    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Enable all outcoming responses
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
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

variable "server_port" {
    description = "Port for HTTP requests"
    type = number
    default = 8080
}

output "alb_dns_name" {
    value = aws_lb.example.dns_name
    description = "App load balancer domain name"
}