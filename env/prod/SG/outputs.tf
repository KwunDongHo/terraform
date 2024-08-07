output "SSH_SG" {
  value       = module.SSH_SG.security_group_id
  description = "SSH Security-Group Output"
}

output "HTTP_SG" {
  value       = module.HTTP_SG.security_group_id
  description = "HTTP Security-Group Output"
}

output "HTTPS_SG" {
  value       = module.HTTPS_SG.security_group_id
  description = "HTTPS Security-Group Output"
}

output "RDS_SG" {
  value       = module.RDS_SG.security_group_id
  description = "SDS Security-Group Output"
}

output "REDIS_SG" {
  value       = module.REDIS_SG.security_group_id
  description = "REDIS Security-Group Output"
}

output "NAT_SG" {
  value       = module.NAT_SG.security_group_id
  description = "NAT Security-Group Output"
}

output "EFS_SG" {
  value       = module.EFS_SG.security_group_id
  description = "EFS Security-Group Output"
}
