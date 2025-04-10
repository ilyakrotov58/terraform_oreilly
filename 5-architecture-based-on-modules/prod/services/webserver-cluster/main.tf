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

    aws_lb_target_group_name = "aws-lb-target-group-prod"
}

# Planned increasing of asg capacity from 9 am every day
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
    scheduled_action_name = "scale_out_during_business_hours"
    min_size = 2
    max_size = 5
    desired_capacity = 5
    recurrence = "0 9 * * *"

    autoscaling_group_name = module.webserver_cluster.asg_name
}

# Planned decreasing of asg capacity from 5 pm every day
resource "aws_autoscaling_schedule" "scale_in_at_night" {
    scheduled_action_name = "scale_in_at_night"
    min_size = 2
    max_size = 5
    desired_capacity = 2
    recurrence = "0 17 * * *"

    autoscaling_group_name = module.webserver_cluster.asg_name
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