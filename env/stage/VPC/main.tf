terraform {
  backend "s3" {
    bucket         = "sportslink-terraform-project"
    key            = "Stage/VPC/terraform.tfstate"
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

# Prod VPC
module "Prod_vpc" {
  source = "github.com/terraform-eks/terraform-aws-vpc"
  name   = "Stage_vpc"
  cidr   = local.cidr

  azs                 = local.azs
  public_subnets      = local.public_subnet
  private_subnets     = local.private_subnets
  elasticache_subnets = local.elasticache_subnets
  database_subnets    = local.database_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  elasticache_subnet_group_name = local.elasticache_subnet_group_name

  create_database_subnet_group           = false

  tags = {
    "TerraformManaged" = "true"
  }

  public_subnet_tags = {
  "kubernetes.io/role/elb"       = 1
  "kubernetes.io/cluster/sportlink" = "shared"
  }
}
