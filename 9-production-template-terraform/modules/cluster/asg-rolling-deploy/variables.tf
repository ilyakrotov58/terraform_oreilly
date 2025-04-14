variable "cluster_name" {
    description = "The name to use for all cluster resources"
    type = string
}

variable "ami" {
    description = "The AMI to run in the cluster"
    type = string
    default = "ami-0fb653ca2d3203ac1"
}

variable "instance_type" {
    description = "The type of EC2 instances to run"
    type = string

    validation {
        condition = contains(["t2.micro", "t3.micro"], var.instance_type)
        error_message = "Only free tier is allowed: t2.micro or t3.micro"
    }
}

variable "min_size" {
    description = "Minimum number of EC2 instances in the ASG"
    type = number

    validation {
        condition = var.min_size > 0
        error_message = "ASGs can't be empty"
    }

    validation {
        condition = var.min_size <= 10
        error_message = "ASG must have 10 or fewer instances to keep costs down"
    }
}

variable "max_size" {
    description = "Maximum number of EC2 instances in the ASG"
    type = number
}

variable "custom_tags" {
    description = "Custom tags to set on the Instances in the ASG"
    type = map(string)
    default = {}
}

variable "enable_autoscaling" {
    description = "If set to true, enable auto scaling"
    type = bool
}

variable "server_port" {
    description = "Port for HTTP requests"
    type = number
    default = 8080
}

variable "subnet_ids" {
    description = "The subnet ids to deploy to"
    type = list(string)
}

variable "target_group_arns" {
    description = "The ARNs of the ELB target groups in witch to register Instances"
    type = list(string)
    default = []
}

variable "health_check_type" {
    description = "The type of health check to perform. Must be one of: EC2, ELB"
    type = string
    default = "EC2"
}

variable "user_data" {
    description = "The User Data script to run in each Instance at boot"
    type = string
    default = null
}