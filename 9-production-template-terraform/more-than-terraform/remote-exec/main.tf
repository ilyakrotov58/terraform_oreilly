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

resource "aws_security_group" "instance" {
    ingress {
        from_port = 22
        to_port   = 22
        protocol  = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Just for learning purpuses
# In real project keys shoul be generated outside terraform
resource "tls_private_key" "example" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "aws_key_pair" "generated_key" {
    public_key = tls_private_key.example.public_key_openssh
}

data "aws_ami" "ubuntu" {
    most_recent = true
    owners = ["099720109477"]

    filter {
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
}

resource "aws_instance" "example" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    vpc_security_group_ids = [aws_security_group.instance.id]
    key_name = aws_key_pair.generated_key.key_name

    provisioner "remote-exec" {
        inline = [ "echo \"Hello, World from $(uname -smp)\"" ]
    }

    connection {
        type = "ssh"
        host = self.public_ip
        user = "ubuntu"
        private_key = tls_private_key.example.private_key_pem
    }
}