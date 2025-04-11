terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.94.1"
            configuration_aliases = [ aws.parent, aws.child ]
        }
    }
}

data "aws_caller_identity" "parent" {
    provider = aws.parent
}

data "aws_caller_identity" "child" {
    provider = aws.child
}