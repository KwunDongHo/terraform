terraform {
  backend "s3" {
    bucket         = "sportslink-terraform-project"
    key            = "stage/efs/terraform.tfstate"
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

module "efs" {
  source                = "terraform-aws-modules/efs/aws"
  version               = "1.6.3"
  name                  = "sportlink-monitoring-log"
  performance_mode      = "generalPurpose" # 성능 모드: generalPurpose(범용 모드), maxIO(최대 IO 모드)
  throughput_mode       = "bursting"       # 처리량 모드
  encrypted             = "true"           # 암호화 설정 
  create_security_group = false            # 보안 그룹 자동 생성을 비활성화

  tags = {
    Name = "monitoring-log"
  }

  mount_targets = {
    "ap-northeast-2a" = {
      subnet_id       = data.terraform_remote_state.vpc.outputs.private_subnet_ids[0]
      security_groups = [data.terraform_remote_state.sg.outputs.EFS_SG]
    }
    "ap-northeast-2c" = {
      subnet_id       = data.terraform_remote_state.vpc.outputs.private_subnet_ids[1]
      security_groups = [data.terraform_remote_state.sg.outputs.EFS_SG]
    }
  }
}