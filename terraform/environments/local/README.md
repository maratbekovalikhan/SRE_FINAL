# Local Environment (Minikube)

Deploy the full stack (app + monitoring) to a local Minikube cluster.

## Prerequisites

- [Minikube](https://minikube.sigs.k8s.io/) installed
- [Terraform](https://www.terraform.io/) >= 1.5
- [Docker](https://www.docker.com/) installed

## Quick Start

```bash
# 1. Start Minikube with enough resources
minikube start --cpus=4 --memory=8192

# 2. Enable required addons
minikube addons enable ingress
minikube addons enable metrics-server   # needed for HPA

# 3. Build Docker image inside Minikube's Docker daemon
eval $(minikube docker-env)
docker build -t task-api:local ../../..

# 4. Copy terraform.tfvars.example to terraform.tfvars and set passwords
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values

# 5. Initialize and apply Terraform
terraform init
terraform plan
terraform apply
```

## Accessing the Application

Option 1 — Ingress (add to /etc/hosts):
```bash
echo "$(minikube ip) task-api.local grafana.local" | sudo tee -a /etc/hosts
curl http://task-api.local/health
```

Option 2 — Port forward:
```bash
kubectl port-forward -n task-api svc/task-api-service 8080:80
curl http://localhost:8080/health
```

## Accessing Grafana

```bash
# Via Ingress: http://grafana.local (login: admin / <grafana_admin_password>)
# Via port-forward:
kubectl port-forward -n monitoring svc/kube-prometheus-stack-grafana 3000:80
# Open http://localhost:3000
```

## Cleanup

```bash
terraform destroy
minikube stop
```
