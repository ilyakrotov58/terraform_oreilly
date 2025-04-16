variable "db_username" {
    description = "Username of the example_database_ilia"
    type = string
    sensitive = true
    default = null
}

variable "db_password" {
    description = "Password for the example_database_ilia"
    type = string
    sensitive = true
    default = null
}

variable "db_name" {
    description = "Name of the Database"
    type = string
}