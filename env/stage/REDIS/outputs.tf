output "redis_endpoint" {
  description = "The primary endpoint of the Redis cluster"
  value       = aws_elasticache_replication_group.redis-cluster.primary_endpoint_address
}