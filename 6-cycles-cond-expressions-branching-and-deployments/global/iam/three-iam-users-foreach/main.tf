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

resource "aws_iam_user" "example" {
    for_each = toset(var.user_names)
    name = each.value
}