variable "alb_name" {
    description = "ALB name"
    type = string
}

variable "subnet_ids" {
  description = "The subnet IDs to deploy to"
  type        = list(string)
}