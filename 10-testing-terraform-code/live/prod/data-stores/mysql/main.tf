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
    alias = "primary"
}

provider "aws" {
    region = "us-west-1"
    alias = "replica"
}

module "mysql_primary" {
    source = "../../../../modules/data-stores/mysql"

    providers = {
        aws = aws.primary
    }

    db_username = var.db_username
    db_password = var.db_password

    backup_retention_preiod = 1
}

module "mysql_replica" {
    source = "../../../../modules/data-stores/mysql"

    providers = {
        aws = aws.replica
    }

    replicate_source_db = module.mysql_primary.arn
}

terraform {
    backend "s3" {
        bucket = "terraform-s3-bucket-ilia-example"
        key = "prod/data-stores/mysql/terraform.tfstate"
        region = "us-east-2"

        dynamodb_table = "terraform_s3_ilia_example-locks"
        encrypt = true
    }
}