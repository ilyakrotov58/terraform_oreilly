output "all_users" {
    value = aws_iam_user.example
}

output "all_arns" {
    value = values(aws_iam_user.example)[*].arn
}