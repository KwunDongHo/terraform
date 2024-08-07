data "aws_iam_user" "EKS_Admin_ID" {
  user_name = "terraform_user" # 실제 IAM 사용자 이름으로 변경하세요.
}