output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.Prod_vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets"
  value       = module.Prod_vpc.public_subnets
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = module.Prod_vpc.private_subnets
}

output "database_subnet_ids" {
  description = "The IDs of the database subnets"
  value       = module.Prod_vpc.database_subnets
}

output "elasticache_subnets" {
  description = "The IDs of the elasticache_subnets"
  value       = module.Prod_vpc.elasticache_subnets
}

output "private_subnets" {
  description = "The private subnets CIDR blocks"
  value       = module.Prod_vpc.private_subnets_cidr_blocks
}

output "database_subnets" {
  description = "The database_subnets CIDR blocks"
  value       = module.Prod_vpc.database_subnets_cidr_blocks
}

output "elasticache_subnet_group_name" {
  value = module.Prod_vpc.elasticache_subnet_group_name
}
