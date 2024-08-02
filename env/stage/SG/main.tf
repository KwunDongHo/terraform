terraform {
  backend "s3" {
    bucket         = "sportslink-terraform-project"
    key            = "Stage/SG/terraform.tfstate"
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

# SSH SG
module "SSH_SG" {
  source          = "github.com/terraform-eks/terraform-aws-security-group"
  name            = "SSH_SG"
  description     = "SSH Port Allow"
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  use_name_prefix = "false"

  ingress_with_cidr_blocks = [
    {
      from_port   = local.ssh_port
      to_port     = local.ssh_port
      protocol    = local.tcp_protocol
      description = "SSH Port Allow"
      cidr_blocks = local.all_network
    },
    {
      from_port   = local.any_protocol
      to_port     = local.any_protocol
      protocol    = local.icmp_protocol
      description = "ICMP"
      cidr_blocks = local.all_network
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = local.all_network
    }
  ]
}


# HTTP
module "HTTP_SG" {
  source          = "github.com/terraform-eks/terraform-aws-security-group"
  name            = "HTTP_SG"
  description     = "HTTP Port Allow"
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  use_name_prefix = "false"

  ingress_with_cidr_blocks = [
    {
      from_port   = local.http_port
      to_port     = local.http_port
      protocol    = local.tcp_protocol
      description = "HTTP Port Allow"
      cidr_blocks = local.all_network
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = local.all_network
    }
  ]
}

module "HTTPS_SG" {
  source          = "github.com/terraform-eks/terraform-aws-security-group"
  name            = "HTTPS_SG"
  description     = "HTTPS Port Allow"
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  use_name_prefix = "false"

  ingress_with_cidr_blocks = [
    {
      from_port   = local.https_port
      to_port     = local.https_port
      protocol    = local.tcp_protocol
      description = "HTTPS Port Allow"
      cidr_blocks = local.all_network
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = local.all_network
    }
  ]
}


# RDS SG
module "RDS_SG" {
  source          = "github.com/terraform-eks/terraform-aws-security-group"
  name            = "RDS_SG"
  description     = "DB Port Allow"
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  use_name_prefix = "false"

  ingress_with_cidr_blocks = [
    {
      from_port   = local.db_port
      to_port     = local.db_port
      protocol    = local.tcp_protocol
      description = "DB Port Allow"
      cidr_blocks = data.terraform_remote_state.vpc.outputs.database_subnets[0]
    },
    {
      from_port   = local.db_port
      to_port     = local.db_port
      protocol    = local.tcp_protocol
      description = "DB Port Allow"
      cidr_blocks = data.terraform_remote_state.vpc.outputs.database_subnets[1]
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = local.all_network
    }
  ]
}


# REDIS SG
module "REDIS_SG" {
  source          = "github.com/terraform-eks/terraform-aws-security-group"
  name            = "REDIS_SG"
  description     = "REDIS Port Allow"
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  use_name_prefix = "false"

  ingress_with_cidr_blocks = [
    {
      from_port   = local.redis_port
      to_port     = local.redis_port
      protocol    = local.tcp_protocol
      description = "REDIS Port Allow"
      cidr_blocks = "192.168.30.0/24"
    },
    {
      from_port   = local.redis_port
      to_port     = local.redis_port
      protocol    = local.tcp_protocol
      description = "REDIS Port Allow"
      cidr_blocks = "192.168.40.0/24"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = local.all_network
    }
  ]
}

module "NAT_SG" {
  source          = "terraform-aws-modules/security-group/aws"
  version         = "5.1.0"
  name            = "NAT_SG"
  description     = "All Traffic"
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  use_name_prefix = "false"

  ingress_with_cidr_blocks = [
    {
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets[0]
    },
    {
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = data.terraform_remote_state.vpc.outputs.private_subnets[1]
    }
  ]
  egress_with_cidr_blocks = [
    {
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = local.all_network
    }
  ]
}

# EFS
module "EFS_SG" {
  source          = "terraform-aws-modules/security-group/aws"
  version         = "5.1.0"
  name            = "EFS_SG"
  description     = "EFS Port Allow"
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  use_name_prefix = "false"

  ingress_with_cidr_blocks = [
    {
      from_port   = local.efs_port
      to_port     = local.efs_port
      protocol    = local.tcp_protocol
      description = "REDIS Port Allow"
      cidr_blocks = "192.168.10.0/24"
    },
    {
      from_port   = local.efs_port
      to_port     = local.efs_port
      protocol    = local.tcp_protocol
      description = "REDIS Port Allow"
      cidr_blocks = "192.168.20.0/24"
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = local.any_port
      to_port     = local.any_port
      protocol    = local.any_protocol
      cidr_blocks = local.all_network
    }
  ]
}
