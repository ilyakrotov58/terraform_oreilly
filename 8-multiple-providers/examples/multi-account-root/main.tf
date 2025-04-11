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
    alias = "parent"
}

provider "aws" {
    region = "us-east-2"
    alias = "child"

    assume_role {
        role_arn = "arn:aws:iam::132983751556:role/OrganizationAccountAccessRole"
    }
}

data "aws_caller_identity" "parent" {
    provider = aws.parent
}

data "aws_caller_identity" "child" {
    provider = aws.child
}