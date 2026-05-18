# AWS EKS Module

This module is a **stub** for cloud deployment. It is not applied in the local
environment. Its purpose is to demonstrate architectural readiness to migrate
from local Minikube to a managed Kubernetes cluster on AWS.

## What it provisions (when uncommented)

- **VPC** with public/private subnets across 3 AZs (via `terraform-aws-modules/vpc`)
- **EKS cluster** with two node groups (via `terraform-aws-modules/eks`):
  - `general` — on-demand `t3.medium` (2-5 nodes)
  - `spot` — spot instances for cost optimization (0-5 nodes)
- **Managed addons**: vpc-cni, coredns, kube-proxy, aws-ebs-csi-driver
- **IRSA** for EBS CSI driver

## How to use

1. Configure AWS credentials:
   ```bash
   aws configure
   ```

2. Uncomment all resources in `main.tf`.

3. Initialize and apply:
   ```bash
   cd terraform/environments/aws
   terraform init
   terraform plan
   terraform apply
   ```

4. Configure kubectl:
   ```bash
   aws eks update-kubeconfig --name <cluster_name> --region us-east-1
   ```

## Prerequisites

- AWS account with permissions for VPC, EKS, IAM, EC2
- S3 bucket + DynamoDB table for remote state (see `environments/aws/backend.tf`)
- Terraform >= 1.5
