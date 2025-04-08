variable "user_names" {
    description = "Create IAM user with these names"
    type = list(string)
    default = [ "neo", "trinity", "morpheus" ]
}