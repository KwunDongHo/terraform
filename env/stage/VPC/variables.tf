# Local Variable 정의
locals {
  cidr                = "192.168.0.0/16"
  azs                 = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnet       = ["192.168.1.0/24", "192.168.2.0/24"]
  private_subnets     = ["192.168.10.0/24", "192.168.20.0/24"]
  elasticache_subnets = ["192.168.30.0/24", "192.168.40.0/24"]
  database_subnets    = ["192.168.50.0/24", "192.168.60.0/24"]

  elasticache_subnet_group_name = "Redis-subnet-group"
}
