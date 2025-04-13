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

# S3 AWS bucket for collecting terrafom state
resource "aws_s3_bucket" "terraform_state" {
    bucket = "terraform-s3-bucket-ilia-example"

    # Preventing bucket removal
    lifecycle {
        prevent_destroy = false
    }
}

# Enable version control to be able to see the history of terraform state
# files and be able to roll back to them
resource "aws_s3_bucket_versioning" "enabled" {
    bucket = aws_s3_bucket.terraform_state.id

    versioning_configuration {
        status = "Enabled"
    }
}

# Turn on encryption of all files on the server side
resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
    bucket = aws_s3_bucket.terraform_state.id

    rule {
        apply_server_side_encryption_by_default {
            sse_algorithm = "AES256"
        }
    }
}

# Make sure that nobody will be able to make bucket public 
resource "aws_s3_bucket_public_access_block" "public_access" {
    bucket = aws_s3_bucket.terraform_state.id

    block_public_acls = true
    block_public_policy = true
    ignore_public_acls = true
    restrict_public_buckets = true
}

# Blocking system to prevent race condition
# We use it to make sure that several people can't run terraform apply concurrently
resource "aws_dynamodb_table" "terraform_locks" {
    name = "terraform_s3_ilia_example-locks"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "LockID"

    attribute {
        name = "LockID"
        type = "S"
    }
}