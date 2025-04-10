
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

# Information about current user
data "aws_caller_identity" "self" {}

# Key's policy
data "aws_iam_policy_document" "cmk_admin_policy" {
    statement {
        effect = "Allow"
        resources = ["*"]
        actions = ["kms:*"]
        principals {
            type = "AWS"
            identifiers = [data.aws_caller_identity.self.arn]
        }
    }
}

# Custom Managed Key (CMK)
resource "aws_kms_key" "cmk" {
    policy = data.aws_iam_policy_document.cmk_admin_policy.json
}

# Alias for the key cause key id is way to long
resource "aws_kms_alias" "cmk" {
    name = "alias/kms-cmk-example"
    target_key_id = aws_kms_key.cmk.id
}

# For decrypting db-creds.yml.encrypted
data "aws_kms_secrets" "creds" {
    secret {
        name = "db"
        payload = file("${path.module}/db-creds.yml.encrypted")
    }
}

locals {
    db_creds = yamldecode(data.aws_kms_secrets.creds.plaintext["db"])
}

resource "aws_db_instance" "example" {
    identifier_prefix = "terraform-up-and-running"
    engine              = "mysql"
    allocated_storage   = 5
    instance_class      = "db.t3.micro"
    skip_final_snapshot = true
    db_name             = var.db_name

    username = local.db_creds.username
    password = local.db_creds.password
}

