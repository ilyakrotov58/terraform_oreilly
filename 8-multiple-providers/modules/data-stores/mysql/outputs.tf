output "adress" {
    value = aws_db_instance.example.address
    description = "DB endpoint"
}

output "port" {
    value = aws_db_instance.example.port
    description = "DB port"
}

output "arn" {
    value = aws_db_instance.example.arn
    description = "The ARN of the database"
}