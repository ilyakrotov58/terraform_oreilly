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

module "hello_world_app" {
  source = "../../../../modules/services/hello-world-app"

  server_text = var.server_text

  environment            = var.environment
  db_remote_state_bucket = "terraform-s3-bucket-ilia-example"
  db_remote_state_key    = "prod/data-stores/mysql/terraform.tfstate"

  instance_type      = "t2.micro"
  min_size           = 2
  max_size           = 2
  enable_autoscaling = false
  ami                = data.aws_ami.ubuntu.id
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

terraform {
    backend "s3" {
        bucket = "terraform-s3-bucket-ilia-example"
        key = "prod/services/hello-world-app/terraform.tfstate"
        region = "us-east-2"

        dynamodb_table = "terraform_s3_ilia_example-locks"
        encrypt = true
    }
}