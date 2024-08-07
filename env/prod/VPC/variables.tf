# Local Variable 정의
locals {
  cidr                = "10.10.0.0/16"
  azs                 = ["ap-northeast-2a", "ap-northeast-2c"]
  public_subnet       = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnets     = ["10.10.10.0/24", "10.10.20.0/24"]
  elasticache_subnets = ["10.10.30.0/24", "10.10.40.0/24"]
  database_subnets    = ["10.10.50.0/24", "10.10.60.0/24"]

  elasticache_subnet_group_name = "Redis-subnet-groups"
}
