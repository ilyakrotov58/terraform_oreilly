variable "db_remote_state_bucket" {
    description = "The name of the S3 bucket for the DB's remote state"
    type = string
}

variable "db_remote_state_key" {
    description = "The path for the database's remote state in S3"
    type = string
}

variable "server_port" {
    description = "Port for HTTP requests"
    type = number
    default = 8080
}

variable "environment" {
    description = "The name of the environment deploying to"
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
}

variable "server_text" {
    description = "The text to the web server should return"
    type = string
    default = "Hello, World!"
}

variable "min_size" {
    description = "Minimum number of EC2 instances in the ASG"
    type = number
}

variable "max_size" {
    description = "Maximum number of EC2 instances in the ASG"
    type = number
}

variable "enable_autoscaling" {
    description = "If set to true, enable auto scaling"
    type = bool
}

variable "custom_tags" {
    description = "Custom tags to set on the Instances in the ASG"
    type = map(string)
    default = {}
}