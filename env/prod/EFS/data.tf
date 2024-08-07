data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket         = "sportslink-terraform-project"
    key            = "Prod/VPC/terraform.tfstate"
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
    key            = "Prod/SG/terraform.tfstate"
    region         = "ap-northeast-2"
    profile        = "terraform_user"
    dynamodb_table = "sportslink-terraform-project"
    encrypt        = true
  }
}