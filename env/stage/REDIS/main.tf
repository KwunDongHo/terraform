terraform {
  backend "s3" {
    bucket         = "sportslink-terraform-project"
    key            = "Stage/redis/terraform.tfstate"
    region         = "ap-northeast-2"
    profile        = "terraform_user"
    dynamodb_table = "sportslink-terraform-project"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform_user"
}

# # Redis Subnet Group 생성
# resource "aws_elasticache_subnet_group" "redis-subnet-group" {
#   name       = data.terraform_remote_state.vpc.outputs.elasticache_subnet_group_name
#   subnet_ids = data.terraform_remote_state.vpc.outputs.elasticache_subnets
#   tags = {
#     Name = "Redis-subnet-group"
#   }
# }

# Redis 클러스터 생성
resource "aws_elasticache_replication_group" "redis-cluster" {
  automatic_failover_enabled  = true
  preferred_cache_cluster_azs = ["ap-northeast-2a", "ap-northeast-2c"]
  multi_az_enabled            = true
  replication_group_id        = "redis"
  description                 = "redis"
  node_type                   = "cache.t2.micro"
  num_cache_clusters          = 2
  parameter_group_name        = "default.redis7"
  engine_version              = "7.1"
  subnet_group_name           = data.terraform_remote_state.vpc.outputs.elasticache_subnet_group_name
  security_group_ids          = [data.terraform_remote_state.sg.outputs.REDIS_SG]

  tags = {
    Name = "Redis_Cluster"
    "TerraformManaged" = "true"
  }
}

# Redis 보안 그룹 데이터 소스
data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = "sportslink-terraform-project"
    key            = "Stage/VPC/terraform.tfstate"
    region         = "ap-northeast-2"
    profile        = "terraform_user"
    dynamodb_table = "sportslink-terraform-project"
    encrypt        = true
  }
}

# VPC 및 서브넷 데이터 소스
data "terraform_remote_state" "sg" {
  backend = "s3"
  config = {
    bucket         = "sportslink-terraform-project"
    key            = "Stage/SG/terraform.tfstate"
    region         = "ap-northeast-2"
    profile        = "terraform_user"
    dynamodb_table = "sportslink-terraform-project"
    encrypt        = true
  }
}
