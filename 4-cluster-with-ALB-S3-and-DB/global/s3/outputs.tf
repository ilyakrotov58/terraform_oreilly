output "s3_bucket_arn" {
    value = aws_s3_bucket.terraform_state.arn
    description = "Amazon resource name of the S3 bucket"
}

output "dynamodb_table_name" {
    value = aws_dynamodb_table.terraform_locks.name
    description = "Name of the DynamoDB table"
}