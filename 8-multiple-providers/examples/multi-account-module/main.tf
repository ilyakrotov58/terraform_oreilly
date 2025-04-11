module "multi-account-example" {
    source = "../../modules/multi-account"

    providers = {
        aws.parent = aws.parent
        aws.child = aws.child
    }
}

provider "aws" {
    region = "us-east-2"
    alias = "parent"
}

provider "aws" {
    region = "us-east-2"
    alias = "child"

    assume_role {
        role_arn = "arn:aws:iam::132983751556:role/OrganizationAccountAccessRole"
    }
}