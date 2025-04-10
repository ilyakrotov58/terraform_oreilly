# This setup gives the EC2 instance (for example, with Jenkins on it) an IAM role.
# The role has permission to use AWS (like EC2 actions).
# 
# Jenkins can use this role to run AWS commands (like aws cli or terraform)
# without needing any AWS access keys.


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

# Create an EC2 instance with an attached IAM Instance Profile
# This allows the instance to assume an IAM role and interact with AWS services
resource "aws_instance" "example" {
    ami = "ami-0fb653ca2d3203ac1"
    instance_type = "t2.micro"

    # Attach the IAM role via instance profile
    iam_instance_profile = aws_iam_instance_profile.instance.name
}

# Trust policy: allow EC2 to assume a role
# With this code EC2 service can give itself IAM role
data "aws_iam_policy_document" "assume_role" {
    statement {
        effect = "Allow"
        actions = ["sts:AssumeRole"]

        principals {
            type = "Service"
            identifiers = ["ec2.amazonaws.com"]
        }
    }
}

# Create the IAM role for EC2
resource "aws_iam_role" "instance" {
    name_prefix = var.name
    assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# Define what EC2 can do — here: full EC2 access
data "aws_iam_policy_document" "ec2_admin_permissions" {
    statement {
        effect = "Allow"
        actions = ["ec2:*"]
        resources = ["*"]
    }
}

# Attach policy to the IAM role
resource "aws_iam_role_policy" "example" {
    role = aws_iam_role.instance.id
    policy = data.aws_iam_policy_document.ec2_admin_permissions.json
}

# Create instance profile that wraps the IAM role
resource "aws_iam_instance_profile" "instance" {
    role = aws_iam_role.instance.name
}

