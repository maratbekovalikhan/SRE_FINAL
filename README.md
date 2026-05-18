# SRE Capstone: E-Commerce Platform — Production Readiness Review

**Team:** Alihan & Nurassyl | **Cloud:** AWS | **Cluster:** EKS

---

## Repository Structure

```
sre-capstone/
├── terraform/          # IaC — AWS EKS, VPC, ECR (Alihan)
├── app/                # Flask e-commerce microservice
├── .github/workflows/  # CI/CD pipeline (Alihan)
├── k8s/                # Kubernetes manifests + HPA
├── monitoring/
│   ├── prometheus/     # prometheus.yml + alert_rules.yml (Nurassyl)
│   ├── grafana/        # Dashboard JSON (Nurassyl)
│   └── alertmanager/   # alertmanager.yml (Nurassyl)
└── locust/             # Load testing (Nurassyl)
```

## Quick Start

### Fast Local Demo
```bash
cd /Users/arslanmaratbekov/Downloads/sre-capstone
scripts/start_demo.sh
```

Local URLs:
- App: `http://127.0.0.1:8000`
- Prometheus: `http://127.0.0.1:9090`
- Alertmanager: `http://127.0.0.1:9093`
- Grafana: `http://127.0.0.1:3000` (`admin` / `admin`)

### 1. Provision Infrastructure (Alihan)
```bash
# Bootstrap remote state backend once
cd terraform/bootstrap
terraform init
terraform apply

# Provision the main infrastructure
cd ..
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

### 2. Deploy Application
```bash
# Update kubeconfig
aws eks update-kubeconfig --region us-east-1 --name sre-ecommerce-cluster

# Required for HPA CPU metrics in EKS
./scripts/install_metrics_server.sh

# Render ECR image into manifest and deploy
IMAGE_URI=<AWS_ACCOUNT_ID>.dkr.ecr.us-east-1.amazonaws.com/sre-ecommerce-app:latest
sed "s|IMAGE_PLACEHOLDER|$IMAGE_URI|g" k8s/deployment.yaml | kubectl apply -f -

# Verify
kubectl get pods -n production
```

### 3. Deploy Monitoring Stack (Nurassyl)
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  -f monitoring/kube-prometheus-stack-values.yml

kubectl apply -f monitoring/servicemonitor.yaml
kubectl apply -f monitoring/prometheus-rule.yaml

# Grafana -> Dashboards -> Import -> monitoring/grafana/ecommerce-dashboard.json
kubectl port-forward svc/prometheus-grafana 3000:80 -n monitoring
```

### 4. Load Testing (Nurassyl)
```bash
pip install locust
locust -f locust/locustfile.py --host=http://<SERVICE_URL> \
  --users 100 --spawn-rate 10 --run-time 5m --headless
```

For a local load test without extra packages:
```bash
app/.venv/bin/python scripts/load_test.py --url http://127.0.0.1:8000 --requests 300 --concurrency 30
```

## SLOs

| SLI | SLO | Alert Threshold |
|-----|-----|-----------------|
| Availability | ≥ 99.9% | Error rate > 0.1% |
| Latency p99 | < 500ms | p99 > 500ms for 3min |
| Order success rate | ≥ 99.5% | < 99% for 10min |

## CI/CD Secrets Required

Set these in GitHub → Settings → Secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

For the manual deployment example above, replace `<AWS_ACCOUNT_ID>` in `IMAGE_URI`
with your AWS account ID.
