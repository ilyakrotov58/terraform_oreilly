output "parent_account_id" {
    value = data.aws_caller_identity.parent.id
    description = "The Id of the child AWS account"
}

output "child_account_id" {
    value = data.aws_caller_identity.child.id
    description = "The Id of the parent AWS account"
}