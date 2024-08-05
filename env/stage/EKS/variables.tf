locals {
  cluster_name    = "sportlink-eks"
  cluster_version = "1.30"
  cluster_admin   = data.aws_iam_user.EKS_Admin_ID.user_id

  # EKS Cluster OIDC 추출 
  oidc_url           = data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer
  cluster_id_matches = regex(".*id/(.+)$", local.oidc_url)
  cluster_id         = length(local.cluster_id_matches) > 0 ? local.cluster_id_matches[0] : ""

  tags = {
    cluster_name = "sportlink-eks"
  }
}