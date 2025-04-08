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

    cluster_name = "webservices-stage"
    db_remote_state_bucket = "terraform-s3-bucket-ilia-example"
    db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"
    instance_type = "t2.micro"
    min_size = 2
    max_size = 2
    enable_autoscaling = false

    aws_lb_target_group_name = "aws-lb-target-group-stage"
}

resource "aws_security_group_rule" "allow_testing_inbound" {
    type = "ingress"
    security_group_id = module.webserver_cluster.alb_security_group_id

    from_port = 12345
    to_port = 12345
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}

# Bucket for saving state
# Located in 4_S3_bucket
terraform {
    backend "s3" {
        bucket = "terraform-s3-bucket-ilia-example"
        key = "stage/services/webserver-cluster/terraform.tfstate"
        region = "us-east-2"

        dynamodb_table = "terraform_s3_ilia_example-locks"
        encrypt = true
    }
}