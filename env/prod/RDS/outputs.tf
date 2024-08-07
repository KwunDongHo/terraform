output "db_name" {
  description = "RDS 데이터베이스의 이름"
  value       = var.db_name
}

output "db_username" {
  description = "RDS 데이터베이스의 사용자 이름"
  value       = var.db_username
}

output "db_password" {
  description = "RDS 데이터베이스의 비밀번호"
  value       = var.db_password
}
