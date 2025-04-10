provider "aws" {
    region = "us-east-2"
}

data "aws_secretsmanager_secret_version" "creds" {
    secret_id = "db-creds"
}

locals {
    db_creds = jsondecode(
        data.aws_secretsmanager_secret_version.creds.secret_string
    )
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