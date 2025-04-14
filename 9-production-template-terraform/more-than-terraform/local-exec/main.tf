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

resource "aws_instance" "example" {
    ami = "ami-0fb653ca2d3203ac1"
    instance_type = "t2.micro"
    
    provisioner "local-exec" {
        command = "echo \"Hello, World from $(uname -smp)\""
    }
}