terraform {
  backend "s3" {
    bucket         = "sportslink-terraform-project"
    key            = "Stage/RDS/terraform.tfstate"
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

# 데이터베이스 서브넷 그룹 생성
resource "aws_db_subnet_group" "sportlink_subnet_group" {
  name       = "sportlink-subnet-group"
  subnet_ids = data.terraform_remote_state.vpc.outputs.database_subnet_ids

  tags = {
    Name = "SportLink-subnet-group"
  }
}

module "RDS" {
  source                              = "github.com/terraform-eks/terraform-aws-rds"
  identifier                          = "sportlink-rds" # 식별이름 : 알파벳 소문자, 하이픈만 사용가능
  engine                              = "mysql"
  engine_version                      = "8.0.35"
  instance_class                      = "db.t3.micro"
  allocated_storage                   = 5
  multi_az                            = true       # 선택사항 (사용 : true)
  iam_database_authentication_enabled = true       # IAM 계정 RDS 인증 사용
  manage_master_user_password         = false      # SecretManager: True(기본값) / Password:false
  skip_final_snapshot                 = true       # RDS Instance 삭제 시 Snapshot 생성여부 결정
  family                              = "mysql8.0" # DB parameter group (Required Option)
  parameters = [
    {
      name  = "character_set_client"
      value = "utf8mb4"
    },
    {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  ]

  major_engine_version = "8.0" # DB option group (Required Option) Engine마다 지원하는 옵션이 다르다. 
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password # Env or Secret Manager 사용권장!
  port                 = var.db_port
  # DB subnet group & DB Security-Group
  db_subnet_group_name   = aws_db_subnet_group.sportlink_subnet_group.name
  subnet_ids             = data.terraform_remote_state.vpc.outputs.database_subnet_ids
  vpc_security_group_ids = [data.terraform_remote_state.sg.outputs.RDS_SG]
}