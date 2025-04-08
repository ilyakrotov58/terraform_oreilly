provider "aws" {
    region = "us-east-2"
}

resource "aws_iam_user" "example" {
    name = "neo"
}