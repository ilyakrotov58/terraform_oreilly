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

resource "aws_db_instance" "example" {
    identifier_prefix = "terraform-example-db-ilia"
    engine = "mysql"
    allocated_storage = 10
    instance_class = "db.t3.micro"
    skip_final_snapshot = true
    db_name = "example_database_ilia_stage"

    username = var.db_username
    password = var.db_password
}

terraform {
    backend "s3" {
        bucket = "terraform-s3-bucket-ilia-example"
        key = "stage/data-stores/mysql/terraform.tfstate"
        region = "us-east-2"

        dynamodb_table = "terraform_s3_ilia_example-locks"
        encrypt = true
    }
}