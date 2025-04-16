variable "db_name" {
    description = "Database name"
    type = string
    default = "example_database_stage"
}

variable "db_username" {
    description = "Username of the example_database_ilia"
    type = string
    sensitive = true
}

variable "db_password" {
    description = "Password for the example_database_ilia"
    type = string
    sensitive = true
}