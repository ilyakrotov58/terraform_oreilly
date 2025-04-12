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

provider "kubernetes" {
    host = module.eks_cluster.cluster_endpoint
    cluster_ca_certificate = base64decode(
        module.eks_cluster.cluster_certificate_authority[0].data
    )
    token = data.aws_eks_cluster_auth.cluster.token
}

module "eks_cluster" {
    source = "../../modules/services/eks-cluster"

    name = "example-eks-cluster"
    min_size = 1
    max_size = 2
    desired_size = 1

    instance_types = ["t3.small"]
}

module "simple_webapp" {
    source = "../../modules/services/k8s-app"

    name = "simple-webapp"
    image = "training/webapp"
    replicas = 2
    container_port = 5000

    enviroment_variables = {
        PROVIDER = "Terraform"
    }

    # Apps deploying only after cluster
    depends_on = [ module.eks_cluster ]
}

data "aws_eks_cluster_auth" "cluster" {
    name = module.eks_cluster.cluster_name
}

output "service_endpoint" {
    value = module.simple_webapp.service_endpoint
    description = "The k8s Service endpoint"
}