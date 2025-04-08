variable "user_names" {
    description = "Create IAM user with these names"
    type = list(string)
    default = [ "neo", "trinity", "morpheus" ]
}

variable "hero_thousand_faces" {
    description = "map"
    type = map(string)
    default = {
        neo = "hero"
        trinity = "love_interest"
        morpheus = "mentor"
    }
}