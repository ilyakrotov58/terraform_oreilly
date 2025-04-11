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
    alias = "region_1"
}

provider "aws" {
    region = "us-west-1"
    alias = "region_2"
}

resource "aws_instance" "region_1" {
    provider = aws.region_1

    ami = data.aws_ami.ubuntu_region_1.id
    instance_type = "t2.micro"
}

resource "aws_instance" "region_2" {
    provider = aws.region_2

    ami = data.aws_ami.ubuntu_region_2.id
    instance_type = "t2.micro"
}

data "aws_region" "region_1" {
    provider = aws.region_1
}

data "aws_region" "region_2" {
    provider = aws.region_2
}

output "region_1" {
    value = data.aws_region.region_1
    description = "Name of the first region"
}

output "region_2" {
    value = data.aws_region.region_2
    description = "Name of the second region"
}

data "aws_ami" "ubuntu_region_1" {
  provider = aws.region_1

  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_ami" "ubuntu_region_2" {
  provider = aws.region_2

  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

output "instance_region_1_az" {
    value = aws_instance.region_1.availability_zone
    description = "The availability zone where the instance of the first region deployed"
}

output "instance_region_2_az" {
    value = aws_instance.region_2.availability_zone
    description = "The availability zone where the instance of the second region deployed"
}