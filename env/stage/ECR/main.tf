terraform {
  backend "s3" {
    bucket         = "sportslink-terraform-project"
    key            = "Stage/ECR/terraform.tfstate"
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

module "ecr" {
  source                            = "terraform-aws-modules/ecr/aws"
  repository_name                   = "sportlink"
  repository_read_write_access_arns = [data.aws_iam_user.EKS_Admin_ID.arn]
  create_lifecycle_policy           = false
  repository_image_scan_on_push     = false
  tags = {
    Terraform = "true"
  }
} 