variable "server_port" {
    description = "Port for HTTP requests"
    type = number
    default = 8080
}

variable "cluster_name" {
    description = "The name to use for all cluster resources"
    type = string
}

variable "db_remote_state_bucket" {
    description = "The name of the S3 bucket for the DB's remote state"
    type = string
}

variable "db_remote_state_key" {
    description = "The path for the database's remote state in S3"
    type = string
}

variable "instance_type" {
    description = "The type of EC2 instances to run"
    type = string
}

variable "min_size" {
    description = "Minimum number of EC2 instances in the ASG"
    type = number
}

variable "max_size" {
    description = "Maximum number of EC2 instances in the ASG"
    type = number
}

variable "aws_lb_target_group_name" {
    description = "Load balancer Target group name"
    type = string
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

variable "ami" {
    description = "The AMI to run in the cluster"
    type = string
    default = "ami-0fb653ca2d3203ac1"
}

variable "server_text" {
    description = "The text to the web server should return"
    type = string
    default = "Hello, World!"
}