# ═══════════════════════════════════════════════════════════════════════════
# AWS EKS Module — STUB for cloud deployment
# This code is NOT applied. It demonstrates architectural readiness
# for migrating from local Minikube to a managed Kubernetes cluster.
# To use: uncomment the resources and run terraform init/plan/apply.
# ═══════════════════════════════════════════════════════════════════════════

locals {
  azs = ["${var.region}a", "${var.region}b", "${var.region}c"]

  common_tags = {
    Project   = var.cluster_name
    ManagedBy = "Terraform"
    Team      = "SRE"
  }
}

# ─── VPC ───────────────────────────────────────────────────────────────────

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "5.1.2"
#
#   name = "${var.cluster_name}-vpc"
#   cidr = var.vpc_cidr
#
#   azs             = local.azs
#   private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
#   public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
#
#   enable_nat_gateway   = true
#   single_nat_gateway   = true
#   enable_dns_hostnames = true
#
#   public_subnet_tags = {
#     "kubernetes.io/role/elb" = 1
#   }
#
#   private_subnet_tags = {
#     "kubernetes.io/role/internal-elb" = 1
#   }
#
#   tags = local.common_tags
# }

# ─── EKS Cluster ──────────────────────────────────────────────────────────

# module "eks" {
#   source  = "terraform-aws-modules/eks/aws"
#   version = "20.0.0"
#
#   cluster_name    = var.cluster_name
#   cluster_version = var.cluster_version
#
#   vpc_id                                   = module.vpc.vpc_id
#   subnet_ids                               = module.vpc.private_subnets
#   cluster_endpoint_public_access           = true
#   enable_cluster_creator_admin_permissions = true
#
#   # ── Managed Addons ───────────────────────────────────────────────────────
#   cluster_addons = {
#     vpc-cni = {
#       most_recent = true
#     }
#     coredns = {
#       most_recent = true
#     }
#     kube-proxy = {
#       most_recent = true
#     }
#     aws-ebs-csi-driver = {
#       most_recent              = true
#       service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
#     }
#   }
#
#   # ── Node Groups ──────────────────────────────────────────────────────────
#   eks_managed_node_groups = {
#     general = {
#       name           = "general"
#       instance_types = ["t3.medium"]
#       min_size       = 2
#       max_size       = 5
#       desired_size   = 2
#
#       labels = {
#         role = "general"
#       }
#     }
#
#     spot = {
#       name           = "spot"
#       instance_types = ["t3.medium", "t3.large"]
#       capacity_type  = "SPOT"
#       min_size       = 0
#       max_size       = 5
#       desired_size   = 1
#
#       labels = {
#         role = "spot"
#       }
#
#       taints = [{
#         key    = "spot"
#         value  = "true"
#         effect = "NO_SCHEDULE"
#       }]
#     }
#   }
#
#   tags = local.common_tags
# }

# ─── EBS CSI IRSA (IAM Role for Service Account) ──────────────────────────

# module "ebs_csi_irsa" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "5.30.0"
#
#   role_name             = "${var.cluster_name}-ebs-csi"
#   attach_ebs_csi_policy = true
#
#   oidc_providers = {
#     main = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
#     }
#   }
#
#   tags = local.common_tags
# }
