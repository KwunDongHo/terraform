# Region 및 AWS 계정 정보
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# AWS EKS Cluster Admin
data "aws_iam_user" "EKS_Admin_ID" {
  user_name = "terraform_user"
}