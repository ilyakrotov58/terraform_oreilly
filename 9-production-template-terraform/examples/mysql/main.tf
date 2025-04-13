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

module "mysql" {
    source = "../../modules/data-stores/mysql"

    db_username = var.db_username
    db_password = var.db_password
}