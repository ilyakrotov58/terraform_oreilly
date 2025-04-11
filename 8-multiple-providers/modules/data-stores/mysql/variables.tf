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

variable "backup_retention_preiod" {
    description = "Days to retain backups. Must be > 0 to enable replication"
    type = number
    default = null
}

variable "replicate_source_db" {
    description = "If specified, replicate the RDS database at the given ARN"
    type = string
    default = null
}