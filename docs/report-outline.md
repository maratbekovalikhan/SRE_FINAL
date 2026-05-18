# SRE Capstone Report Outline

## 1. Project Overview
- Service name: SRE Ecommerce Platform
- Goal: prepare a Flask-based e-commerce microservice for production readiness review
- Cloud target: AWS EKS
- Local demo target: Docker Compose / background Flask demo

## 2. Architecture
- Application: Flask service exposing `/`, `/health`, `/products`, `/orders`, `/metrics`
- Containerization: Docker image built from `app/Dockerfile`
- Orchestration: Kubernetes deployment, service, and HPA in `k8s/deployment.yaml`
- Infrastructure as Code: Terraform for VPC, EKS, ECR, and backend bootstrap
- Observability: Prometheus, Grafana, Alertmanager, ServiceMonitor, PrometheusRule

## 3. Infrastructure as Code
- Explain `terraform/bootstrap/` for S3 state bucket and DynamoDB locking
- Explain `terraform/main.tf` for VPC, EKS, and ECR
- Mention reproducibility from scratch using Terraform and remote state

## 4. CI/CD Pipeline
- GitHub Actions workflow in `.github/workflows/ci-cd.yml`
- Steps: checkout, install dependencies, run tests, build image, push to ECR, deploy to EKS
- Include one screenshot of a successful workflow run

## 5. Observability and Alerting
- Prometheus scrape target: application metrics endpoint `/metrics`
- Grafana dashboard: `monitoring/grafana/ecommerce-dashboard.json`
- Alert rules: high error rate, high latency, low order rate, pod crash looping, node resource alerts
- Include screenshots of Grafana dashboard and alert rules / Alertmanager

## 6. SLOs and Scaling
- Availability SLO: 99.9%
- Latency SLO: p99 under 500 ms
- Order success / business metric target
- HPA based on CPU and memory
- Mention `CPU_WORK_ITERATIONS` used for local/demo CPU pressure generation

## 7. Load Testing
- Primary tool: Locust (`locust/locustfile.py`)
- Fallback local tool: `scripts/load_test.py`
- Include summary numbers and screenshots of scaling if using EKS

## 8. Validation Summary
- `make test`
- `scripts/start_demo.sh`
- `scripts/smoke_test.sh`
- `scripts/load_test.py`
- `docker compose config`

## 9. Challenges and Improvements
- Disk-space and Docker constraints during local verification
- Next improvements: real registry credentials, live Alertmanager webhook, EKS live screenshots
