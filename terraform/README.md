# Terraform Infrastructure

Hybrid IaC setup: same modules deploy to local Minikube or AWS EKS.

## Structure

```
terraform/
├── modules/
│   ├── kubernetes-app/    # Namespace, ConfigMap, Secret, PostgreSQL, Redis,
│   │                      # task-api Deployment, Service, Ingress, HPA
│   ├── monitoring/        # kube-prometheus-stack (Prometheus + Grafana),
│   │                      # ServiceMonitor for task-api
│   └── aws-eks/           # EKS + VPC stub (commented out, for defense demo)
├── environments/
│   ├── local/             # Minikube — primary deployment target
│   └── aws/               # AWS EKS — stub for cloud readiness
└── bootstrap/             # S3 backend + DynamoDB lock table (AWS only)
```

## Quick Start (Local)

```bash
minikube start --cpus=4 --memory=8192
minikube addons enable ingress
minikube addons enable metrics-server

eval $(minikube docker-env)
docker build -t task-api:local ../..

cd environments/local
terraform init
terraform plan
terraform apply
```

See [environments/local/README.md](environments/local/README.md) for details.
