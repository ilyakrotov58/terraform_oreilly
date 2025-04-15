terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "5.94.1"
        }
    }
}

resource "aws_db_instance" "example" {
    identifier_prefix = "terraform-example-db-ilia"
    engine = var.replicate_source_db == null ? "mysql" : null
    allocated_storage = 10
    instance_class = "db.t3.micro"
    skip_final_snapshot = true
    db_name = var.replicate_source_db == null ? "example_database_ilia_stage" : null

    # Enable backup
    backup_retention_period = var.backup_retention_preiod

    # If this var is not null, that means DB is replica
    replicate_source_db = var.replicate_source_db

    # Just for the learning purpuses - real examples in 7-managing-secrets-with-terraform
    username = var.replicate_source_db == null ? var.db_username : null
    password = var.replicate_source_db == null ? var.db_password : null
}