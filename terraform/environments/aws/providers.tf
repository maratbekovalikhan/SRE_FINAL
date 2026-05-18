terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.13"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# After EKS is created, configure these providers to point at the cluster.
# Uncomment and fill in data sources once the EKS module is active.

# data "aws_eks_cluster" "cluster" {
#   name = module.eks.cluster_name
# }
#
# data "aws_eks_cluster_auth" "cluster" {
#   name = module.eks.cluster_name
# }

provider "kubernetes" {
  # When using EKS, replace with:
  # host                   = data.aws_eks_cluster.cluster.endpoint
  # cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  # token                  = data.aws_eks_cluster_auth.cluster.token
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
