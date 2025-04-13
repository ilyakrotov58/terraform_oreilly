output "address" {
    value = aws_db_instance.example.address
    description = "DB endpoint"
}

output "port" {
    value = aws_db_instance.example.port
    description = "DB port"
}

