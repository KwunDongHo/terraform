terraform {
  backend "s3" {
    bucket         = "sportslink-terraform-project"
    key            = "Stage/bastion/terraform.tfstate"
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

# BastionHost AWS KEY-Pair Data Source
data "aws_key_pair" "bastion" {
  key_name = "bastion"
}

# BastionHost Instance 1
resource "aws_instance" "public1" {
  ami                         = "ami-0edc5427d49d09d2a"
  instance_type               = "t2.micro"
  key_name                    = data.aws_key_pair.bastion.key_name
  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnet_ids[0]
  associate_public_ip_address = true
  vpc_security_group_ids      = [data.terraform_remote_state.sg.outputs.SSH_SG]
  user_data                   = <<-EOF
              #!/bin/bash
              set -e
              set -x

              # 시스템 업데이트
              yum update -y

              # AWS CLI 설치
              if ! command -v aws &> /dev/null; then
                echo "AWS CLI 설치 중..."
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                unzip awscliv2.zip
                sudo ./aws/install
                rm -f awscliv2.zip
              else
                echo "AWS CLI 이미 설치됨"
              fi

              # kubectl 설치
              if ! command -v kubectl &> /dev/null; then
                echo "kubectl 설치 중..."
                curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.13/2023-05-11/bin/linux/amd64/kubectl
                chmod +x kubectl
                sudo mv kubectl /usr/local/bin/
                echo 'export PATH=/usr/local/bin:$PATH' >> ~/.bashrc
                source ~/.bashrc
              else
                echo "kubectl 이미 설치됨"
              fi

              # k9s 설치
              if ! command -v k9s &> /dev/null; then
                echo "k9s 설치 중..."
                curl -L https://github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz -o k9s_Linux_amd64.tar.gz
                tar -zxvf k9s_Linux_amd64.tar.gz
                sudo mv k9s /usr/local/bin/
                rm k9s_Linux_amd64.tar.gz
              else
                echo "k9s 이미 설치됨"
              fi
              EOF
  tags = {
    Name = "sportlink_public1"
  }
}

# # BastionHost EIP for Instance 1
# resource "aws_eip" "public1_eip" {
#   instance = aws_instance.public1.id
#   tags = {
#     Name = "public1_eip"
#   }

#   depends_on = [aws_instance.public1]
# }

# BastionHost Instance 2
resource "aws_instance" "public2" {
  ami                         = "ami-0edc5427d49d09d2a"
  instance_type               = "t2.micro"
  key_name                    = data.aws_key_pair.bastion.key_name
  subnet_id                   = data.terraform_remote_state.vpc.outputs.public_subnet_ids[1]
  associate_public_ip_address = true
  vpc_security_group_ids      = [data.terraform_remote_state.sg.outputs.SSH_SG]
  user_data                   = <<-EOF
              #!/bin/bash
              set -e
              set -x

              # 시스템 업데이트
              yum update -y

              # AWS CLI 설치
              if ! command -v aws &> /dev/null; then
                echo "AWS CLI 설치 중..."
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                unzip awscliv2.zip
                sudo ./aws/install
                rm -f awscliv2.zip
              else
                echo "AWS CLI 이미 설치됨"
              fi

              # kubectl 설치
              if ! command -v kubectl &> /dev/null; then
                echo "kubectl 설치 중..."
                curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.24.13/2023-05-11/bin/linux/amd64/kubectl
                chmod +x kubectl
                sudo mv kubectl /usr/local/bin/
                echo 'export PATH=/usr/local/bin:$PATH' >> ~/.bashrc
                source ~/.bashrc
              else
                echo "kubectl 이미 설치됨"
              fi

              # k9s 설치
              if ! command -v k9s &> /dev/null; then
                echo "k9s 설치 중..."
                curl -L https://github.com/derailed/k9s/releases/download/v0.27.4/k9s_Linux_amd64.tar.gz -o k9s_Linux_amd64.tar.gz
                tar -zxvf k9s_Linux_amd64.tar.gz
                sudo mv k9s /usr/local/bin/
                rm k9s_Linux_amd64.tar.gz
              else
                echo "k9s 이미 설치됨"
              fi
              EOF
  tags = {
    Name = "sportlink_public2"
  }
}

# # BastionHost EIP for Instance 2
# resource "aws_eip" "public2_eip" {
#   instance = aws_instance.public2.id
#   tags = {
#     Name = "public2_eip"
#   }

#   depends_on = [aws_instance.public2]
# }
