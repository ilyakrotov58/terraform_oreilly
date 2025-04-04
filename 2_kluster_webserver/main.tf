provider "aws" {
    region = "us-east-2"
}

resource "aws_autoscaling_group" "example" {
    vpc_zone_identifier = data.aws_subnets.default.ids

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

resource "aws_security_group" "instance" {
    name = "terraform-example-instance"

    ingress {
      from_port   = var.server_port
      to_port     = var.server_port
      protocol    = "tcp"
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