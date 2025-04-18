terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.94.1"
        }
    }
}

provider "aws" {
    region = "us-east-2"
}

module "hello_world_app" {
    source = "../../../modules/services/hello-world-app"

    server_text = "Hello, World!"
    environment = var.environment

    mysql_config = var.mysql_config

    instance_type = "t2.micro"
    min_size = 2
    max_size = 2
    enable_autoscaling = false
    ami = data.aws_ami.ubuntu.id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] 

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}