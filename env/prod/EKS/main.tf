terraform {
  backend "s3" {
    bucket         = "sportslink-terraform-project"
    key            = "Prod/EKS/terraform.tfstate"
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
    key            = "Prod/VPC/terraform.tfstate"
    region         = "ap-northeast-2"
    profile        = "terraform_user"
    dynamodb_table = "sportslink-terraform-project"
    encrypt        = true
  }
}

data "terraform_remote_state" "RDS" {
  backend = "s3"
  config = {
    bucket         = "sportslink-terraform-project"
    key            = "Prod/RDS/terraform.tfstate"
    region         = "ap-northeast-2"
    profile        = "terraform_user"
    dynamodb_table = "sportslink-terraform-project"
    encrypt        = true
  }
}

# AWS EKS Cluster Data Source
data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

# AWS EKS Cluster Auth Data Source
data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  }
}

# Terraform EKS Module DOCS : https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  # EKS Cluster Setting
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version
  vpc_id          = data.terraform_remote_state.vpc.outputs.vpc_id
  subnet_ids      = data.terraform_remote_state.vpc.outputs.private_subnet_ids

  # OIDC(OpenID Connect) 구성 
  enable_irsa = true

  # EKS Worker Node 정의 ( ManagedNode방식 / Launch Template 자동 구성 )
  eks_managed_node_groups = {
    EKS_Worker_Node = {
      name           = "Prod-worker-nodes"
      instance_types = ["t3.small"]
      min_size       = 2
      max_size       = 4
      desired_size   = 3
    }
  }

  # public-subnet(bastion)과 API와 통신하기 위해 설정(443)
  cluster_endpoint_public_access = true

  # K8s ConfigMap Object "aws_auth" 구성
  enable_cluster_creator_admin_permissions = true
}


# # EKS 생성 배포 후  아래 정책 주석 해제하고 배포
# # EFS IRSA Configuration

# # 1. EFS Policy Create

# data "local_file" "efs_policy_json" {
#   filename = "../../../iam_policy/EFSAccessPolicy.json"
# }

# resource "aws_iam_policy" "efs_policy" {
#   name        = "EFSAccessPolicy"
#   description = "Policy to allow access to EFS file systems"
#   policy      = data.local_file.efs_policy_json.content
# }

# # 2. EFS Role Create & Trust relationship / Policy Attachment 

# data "template_file" "efs_role_json" {
#   template = file("../../../iam_role/EFSAssumeRole.json")
#   vars = {
#     account_id = data.aws_caller_identity.current.account_id
#     region     = data.aws_region.current.name
#     cluster_id = local.cluster_id
#   }
# }

# resource "aws_iam_role" "efs_role" {
#   name               = "EFSAccessRole"
#   assume_role_policy = data.template_file.efs_role_json.rendered
# }

# resource "aws_iam_role_policy_attachment" "efs_policy_attachment" {
#   policy_arn = aws_iam_policy.efs_policy.arn
#   role       = aws_iam_role.efs_role.name
# }

# # 3. EFS Addon Install ( Service Account 자동생성 )

# resource "aws_eks_addon" "efs_csi_driver" {
#   cluster_name             = local.cluster_name
#   addon_name               = "aws-efs-csi-driver"
#   service_account_role_arn = aws_iam_role.efs_role.arn
#   depends_on               = [module.eks]
# }

# # AWS Load Balancer Controller IRSA Configuration

# # 1. AWSLoadBalancerController Policy Create

# data "local_file" "alb_controller_policy_json" {
#   filename = "../../../iam_policy/AWSLoadBalancerControllerPolicy.json"
# }

# resource "aws_iam_policy" "alb_controller_policy" {
#   name        = "AWSLoadBalancerControllerPolicy"
#   description = "Policy to allow access to AWSLoadBalancerController"
#   policy      = data.local_file.alb_controller_policy_json.content
# }


# # 2. AWSLoadBalancerController Role Create & Trust relationship / Policy Attachment 

# data "template_file" "alb_controller_role_json" {
#   template = file("../../../iam_role/AWSLoadBalancerControllerAssumeRole.json")
#   vars = {
#     account_id = data.aws_caller_identity.current.account_id
#     region     = data.aws_region.current.name
#     cluster_id = local.cluster_id
#   }
# }

# resource "aws_iam_role" "alb_controller_role" {
#   name               = "AWSLoadBalancerControllerRole"
#   assume_role_policy = data.template_file.alb_controller_role_json.rendered
# }

# resource "aws_iam_role_policy_attachment" "alb_controller_policy_attachment" {
#   policy_arn = aws_iam_policy.alb_controller_policy.arn
#   role       = aws_iam_role.alb_controller_role.name
# }


# # 3. AWSLoadBalancerController Install ( Helm Install )

# #Service Account for AWS Load Balancer Controller
# resource "kubernetes_service_account" "alb_controller_sa" {
#   metadata {
#     name      = "aws-load-balancer-controller"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.alb_controller_role.arn
#     }
#   }
# }

# # Helm Release for AWS Load Balancer Controller
# resource "helm_release" "lb_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"

#   # Values.yml 직접 정의
#   values = [
#     <<EOF
#     serviceAccount:
#       create: false
#       name: aws-load-balancer-controller
#     clusterName: ${local.cluster_name}
#     region: ${data.aws_region.current.name}
#     vpcId: ${data.terraform_remote_state.vpc.outputs.vpc_id}
#     EOF
#   ]
# }

# # Route53(ExternalDNS) IRSA Configuration

# # 1. ExternalDNS Policy Create

# data "local_file" "externalDNS_policy_json" {
#   filename = "../../../iam_policy/ExternalDNSPolicy.json"
# }

# resource "aws_iam_policy" "externalDNS_policy" {
#   name        = "ExternalDNSRoute53AccessPolicy"
#   description = "Policy to allow access to Route53 Hosting Area"
#   policy      = data.local_file.externalDNS_policy_json.content
# }

# # 2. ExternalDNS Role Create & Trust relationship / Policy Attachment 

# data "template_file" "externalDNS_role_json" {
#   template = file("../../../iam_role/ExternalDNSAssumeRole.json")
#   vars = {
#     account_id = data.aws_caller_identity.current.account_id
#     region     = data.aws_region.current.name
#     cluster_id = local.cluster_id
#   }
# }

# resource "aws_iam_role" "externalDNS_role" {
#   name               = "ExternalDNSRole"
#   assume_role_policy = data.template_file.externalDNS_role_json.rendered
# }

# resource "aws_iam_role_policy_attachment" "externalDNS_policy_attachment" {
#   policy_arn = aws_iam_policy.externalDNS_policy.arn
#   role       = aws_iam_role.externalDNS_role.name
# }

# # 3. ExternalDNS Install ( Helm Install )

# # Kubernetes Service Account for ExternalDNS
# resource "kubernetes_service_account" "externalDNS_sa" {
#   metadata {
#     name      = "external-dns"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.externalDNS_role.arn
#     }
#   }
# }

# # Helm Release for ExternalDNS
# resource "helm_release" "external_dns" {
#   name       = "external-dns"
#   repository = "https://charts.bitnami.com/bitnami"
#   chart      = "external-dns"
#   namespace  = "kube-system"

#   # Set을 활용한 Values.yml 정의
#   set {
#     name  = "serviceAccount.create"
#     value = "false"
#   }
#   set {
#     name  = "serviceAccount.name"
#     value = "external-dns"
#   }
#   set {
#     name  = "provider"
#     value = "aws"
#   }
#   set {
#     name  = "aws.region"
#     value = "ap-northeast-2"
#   }
#   set {
#     name  = "domainFilters[0]"
#     value = "sportslink.shop"
#   }
#   set {
#     name  = "policy"
#     value = "sync"
#   }
#   set {
#     name  = "rbac.create"
#     value = "true"
#   }
# }

# # AutoScaling Group IRSA Configuration

# # 1. Cluster AutoScaler Policy Create

# data "local_file" "clusterautoscaler_policy_json" {
#   filename = "../../../iam_policy/ClusterAutoScalerPolicy.json"
# }

# resource "aws_iam_policy" "clusterautoscaler_policy" {
#   name        = "ClusterAutoscalerPolicy"
#   description = "Policy to allow access to AutoScalingGroup"
#   policy      = data.local_file.clusterautoscaler_policy_json.content
# }

# # 2. Cluster AutoScaler Role Create & Trust relationship / Policy Attachment 

# data "template_file" "clusterautoscaler_role_json" {
#   template = file("../../../iam_role/ClusterAutoScalerAssumeRole.json")
#   vars = {
#     account_id = data.aws_caller_identity.current.account_id
#     region     = data.aws_region.current.name
#     cluster_id = local.cluster_id
#   }
# }

# resource "aws_iam_role" "clusterautoscaler_role" {
#   name               = "ClusterAutoscalerRole"
#   assume_role_policy = data.template_file.clusterautoscaler_role_json.rendered
# }

# resource "aws_iam_role_policy_attachment" "clusterautoscaler_policy_attachment" {
#   policy_arn = aws_iam_policy.clusterautoscaler_policy.arn
#   role       = aws_iam_role.clusterautoscaler_role.name
# }

# # 3. Cluster AutoScaler Install ( Helm Install )

# # Kubernetes Service Account for cluster_autoscaler
# resource "kubernetes_service_account" "cluster_autoscaler_sa" {
#   metadata {
#     name      = "cluster-autoscaler"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.clusterautoscaler_role.arn
#     }
#   }
# }

# # Helm Release for Cluster Autoscaler 
# # For Kubernetes 1.24.X: Use Cluster Autoscaler chart version 9.25.0+.
# # For Kubernetes 1.26.X: Use Cluster Autoscaler chart version 9.28.0+.
# # For Kubernetes 1.27.X: Use Cluster Autoscaler chart version 9.29.0+.
# # For Kubernetes 1.29.X: Use Cluster Autoscaler chart version 9.35.0+.

# resource "helm_release" "cluster_autoscaler" {
#   name       = "cluster-autoscaler"
#   namespace  = "kube-system"
#   chart      = "cluster-autoscaler"
#   repository = "https://kubernetes.github.io/autoscaler"
#   version    = "9.35.0"

#   set {
#     name  = "autoDiscovery.clusterName"
#     value = local.cluster_name
#   }
#   set {
#     name  = "awsRegion"
#     value = data.aws_region.current.name
#   }
#   set {
#     name  = "rbac.serviceAccount.create"
#     value = "false"
#   }
#   set {
#     name  = "rbac.serviceAccount.name"
#     value = kubernetes_service_account.cluster_autoscaler_sa.metadata[0].name
#   }
#   set {
#     name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.clusterautoscaler_role.arn
#   }
# }