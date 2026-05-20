# Terraform Infrastructure

Terraform is split into reusable modules plus environment-specific entrypoints.

## Layout

```text
terraform/
├── bootstrap/            optional S3 + DynamoDB remote-state bootstrap
├── environments/
│   ├── local/            active Minikube deployment
│   └── aws/              optional AWS/EKS scaffold
└── modules/
    ├── kubernetes-app/   namespace, secrets, DB, Redis, app, ingress, HPA
    ├── monitoring/       kube-prometheus-stack plus ServiceMonitor
    └── aws-eks/          commented cloud scaffold for defense discussion
```

## Local Quick Start

```bash
./scripts/setup.sh
```

That script starts Minikube, enables required addons, builds the app image inside Minikube, and runs `terraform apply` in `environments/local`.

## Remote State Bootstrap

If you want collaborative AWS-backed state:

```bash
cd terraform/bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

Then uncomment the S3 backend in `environments/aws/backend.tf`.
