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

module "webserver_cluster" {
    # In real projects, this should point to the URL of a remote Git repository containing the module
    # Module versioning should be managed using Git tags

    # The usual workflow is:

    # - When we want to test changes to a module in a staging environment, 
    # we create a new Git tag and push it to the repository of module

    # - After successful testing, we update the tag used in the production environment to the new version

    source = "../../../modules/services/webserver-cluster"

    cluster_name = "webservices-prod"
    db_remote_state_bucket = "terraform-s3-bucket-ilia-example"
    db_remote_state_key = "prod/data-stores/mysql/terraform.tfstate"

    instance_type = "t2.micro"
    min_size = 2
    max_size = 5
    enable_autoscaling = true

    aws_lb_target_group_name = "aws-lb-target-group-prod"

    custom_tags = {
        Owner = "team-ilia"
        ManagedBy = "terraform"
    }
}

# Bucket for saving state
# Located in 4_S3_bucket
terraform {
    backend "s3" {
        bucket = "terraform-s3-bucket-ilia-example"
        key = "prod/services/webserver-cluster/terraform.tfstate"
        region = "us-east-2"

        dynamodb_table = "terraform_s3_ilia_example-locks"
        encrypt = true
    }
}