# SRE Capstone: Production Readiness Report

**Team:** Alihan & Nurassyl  
**Service:** Task Manager API  
**Primary Platform:** Minikube + Kubernetes  
**Optional Cloud Path:** AWS bootstrap + EKS scaffold  
**Date:** May 20, 2026

---

## 1. Executive Summary

This project prepares a FastAPI-based Task Manager API for a Production Readiness Review (PRR). The repository demonstrates reproducible infrastructure, containerized delivery, automated CI/CD, observability, SLO-driven alerting, and horizontal scaling.

The project is intentionally split into two deployment paths:

- `terraform/environments/local`: the primary, fully reproducible demo path used for validation and defense
- `terraform/environments/aws`: an optional cloud scaffold for migration to EKS when AWS credentials are available

---

## 2. System Overview

### 2.1 Application

The service is a small CRUD API for tasks. It exposes:

- `GET /health` for liveness
- `GET /ready` for readiness checks against PostgreSQL and Redis
- `POST /tasks`, `GET /tasks`, `GET /tasks/{id}`, `PUT /tasks/{id}`, `DELETE /tasks/{id}`
- `GET /work` for synthetic latency, failure, and CPU load generation
- `GET /metrics` for Prometheus

### 2.2 Dependencies

- **PostgreSQL** for persistent task storage
- **Redis** for cache acceleration on task reads
- **Prometheus** for metrics collection
- **Grafana** for dashboarding
- **Alertmanager** for alert routing

### 2.3 Deployment Modes

- **Docker Compose** for quick local demo and screenshot capture
- **Kubernetes** for production-style deployment with ingress and HPA
- **Terraform** for reproducible Kubernetes and monitoring resources

---

## 3. Infrastructure as Code

### 3.1 Terraform Structure

```text
terraform/
├── bootstrap/            optional S3 + DynamoDB state bootstrap
├── environments/
│   ├── local/            active Minikube deployment
│   └── aws/              optional AWS/EKS scaffold
└── modules/
    ├── kubernetes-app/   namespace, secrets, DB, Redis, app, ingress, HPA
    ├── monitoring/       kube-prometheus-stack and ServiceMonitor
    └── aws-eks/          cloud migration scaffold
```

### 3.2 Reproducibility

The local deployment is reproducible from scratch:

```bash
./scripts/setup.sh
```

That flow:

1. Starts Minikube
2. Enables ingress and metrics-server
3. Builds the Docker image inside the Minikube Docker daemon
4. Runs `terraform init`
5. Runs `terraform apply`

### 3.3 State Management

- Local Terraform uses a local backend for the demo environment
- Optional remote state is supported through `terraform/bootstrap`, which provisions:
  - an S3 bucket for `terraform.tfstate`
  - a DynamoDB table for state locking

This satisfies the requirement to manage Terraform state cleanly and to document a collaborative remote-state path.

---

## 4. CI/CD

### 4.1 Continuous Integration

The CI workflow validates both code and infrastructure:

- Ruff lint and formatting checks
- pytest test suite
- Terraform `fmt` and `validate`
- Kubernetes manifest validation with `kubeconform`
- Docker image build verification

### 4.2 Continuous Deployment

The CD workflow performs:

1. Docker build and push to GHCR
2. Trivy security scan
3. Automatic deployment to Kubernetes when `KUBE_CONFIG_DATA` is configured in GitHub Actions secrets

Deployment applies:

- namespace
- ConfigMap
- Secret
- PostgreSQL
- Redis
- application deployment and service
- ingress
- HPA

If the monitoring namespace already exists, the workflow also applies:

- `monitoring/servicemonitor.yaml`
- `monitoring/prometheus-rule.yaml`

### 4.3 Registry

Docker images are published to GitHub Container Registry under:

```text
ghcr.io/<owner>/<repo>:sha-<commit>
ghcr.io/<owner>/<repo>:latest
```

---

## 5. Observability

### 5.1 Metrics Collection

The application exports:

- HTTP request counters and latency histograms
- custom task-operation counters
- cache hit and miss counters
- synthetic workload counters
- database query latency histograms

Prometheus scrapes `/metrics` locally through Docker Compose and in Kubernetes through a `ServiceMonitor`.

### 5.2 Grafana Dashboard

The dashboard file is `monitoring/grafana/ecommerce-dashboard.json` and now visualizes the real service metrics:

- Availability SLI
- p99 latency
- Task write success ratio
- Request rate by handler
- Error rate by handler
- Successful task operations
- Cache hit ratio
- Synthetic workload rate

### 5.3 Alerting

The alert rules map directly to the SLOs:

- `HighErrorRate`
- `HighLatency`
- `TaskWriteFailureRate`
- `PodCrashLooping`
- `NodeHighCPU`
- `NodeHighMemory`

Alertmanager is configured with a default receiver so that alerts can be demonstrated safely in local or lab environments without a real Slack webhook.

### 5.4 Screenshots to insert

- Insert Grafana screenshot here
- Insert Prometheus alerts or Alertmanager screenshot here

---

## 6. SLOs and Scaling

### 6.1 SLO Table

| SLI | Definition | SLO | Alert |
|-----|------------|-----|-------|
| Availability | successful requests / total requests | `>= 99.9%` | `HighErrorRate` |
| p99 latency | p99 of `http_request_duration_seconds` | `< 500ms` | `HighLatency` |
| Task write success ratio | successful create/update/delete ops / total write ops | `>= 99%` | `TaskWriteFailureRate` |

### 6.2 Horizontal Pod Autoscaler

The HPA is defined in both Terraform and raw manifests:

- Minimum replicas: `2`
- Maximum replicas: `10`
- Target CPU utilization: `70%`

### 6.3 Load and Scale Test Strategy

The `/work` endpoint supports:

- artificial delay
- artificial error rate
- CPU work via `cpu_iterations`

This allows:

- latency alert demonstrations
- error-rate demonstrations
- CPU-driven HPA scaling demonstrations

### 6.4 Screenshots to insert

- Insert HPA scaling screenshot here
- Insert load test screenshot or JSON summary here

---

## 7. Validation Workflow

### 7.1 Demo Startup

```bash
./scripts/start_demo.sh
```

### 7.2 Smoke Test

```bash
./scripts/smoke_test.sh http://127.0.0.1:8000
```

The smoke test verifies:

- `/health`
- `/ready`
- task creation
- task retrieval
- `/work`
- `/metrics`

### 7.3 Built-in Load Test

```bash
python3 scripts/load_test.py \
  --url http://127.0.0.1:8000 \
  --requests 300 \
  --concurrency 30
```

### 7.4 Evidence Folder

`evidence/` is used for:

- test output
- smoke test output
- load test summary JSON
- compose config export
- manual screenshots

---

## 8. Risks and Future Improvements

- Replace in-repo demo secrets with External Secrets or Vault
- Activate the AWS EKS scaffold fully when cloud credentials are available
- Add a final exported PDF with real screenshots
- Extend alerts to deployment saturation, PVC pressure, and SLO burn-rate style rules
- Introduce GitOps for deployment promotion

---

## 9. Conclusion

The repository now meets the capstone structure more cleanly:

- Infrastructure is reproducible with Terraform
- CI validates both code and infrastructure
- CD can publish and deploy images automatically
- Metrics, dashboards, and alerts match the real service
- HPA and load-testing paths are documented and runnable

The remaining manual step before final submission is to run the stack, capture fresh screenshots, and export the final PDF.
