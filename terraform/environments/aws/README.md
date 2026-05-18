# AWS Environment (EKS)

This is a **stub** environment for deploying to AWS EKS.
It demonstrates that the same Terraform modules used locally can be
applied to a managed Kubernetes cluster in the cloud.

## Status

**Not active** — the EKS module is commented out. This environment exists to
show architectural readiness for cloud migration during the project defense.

## How to activate

1. Configure AWS credentials:
   ```bash
   aws configure
   ```

2. Create the S3 backend (one-time):
   ```bash
   cd terraform/bootstrap
   terraform init && terraform apply
   ```

3. Uncomment the S3 backend in `backend.tf` and the EKS module in `main.tf`.

4. Copy and fill in variables:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

5. Deploy:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

6. Configure kubectl:
   ```bash
   aws eks update-kubeconfig --name sre-capstone --region us-east-1
   ```

## Architecture

```
AWS VPC
├── Public subnets  → NAT Gateway, ALB
└── Private subnets → EKS node groups (general + spot)
    ├── task-api (same module as local)
    ├── PostgreSQL (same module as local)
    ├── Redis (same module as local)
    └── Monitoring stack (same module as local)
```
