# Report Outline

- Goal: show that the Task Manager API is ready for a Production Readiness Review
- Service: FastAPI app exposing `/health`, `/ready`, `/tasks`, `/work`, and `/metrics`
- Data layer: PostgreSQL + Redis
- Runtime: Docker Compose for local demo, Kubernetes for deployment

## Architecture

- Application layer: FastAPI, SQLAlchemy, Redis cache
- Platform layer: Kubernetes namespace, deployments, services, ingress, HPA
- Observability layer: Prometheus, Grafana, Alertmanager
- Delivery layer: GitHub Actions CI/CD

## Infrastructure as Code

- Explain Terraform modules under `terraform/modules/`
- Explain `terraform/environments/local`
- Mention `terraform/bootstrap` for optional AWS remote state bootstrap
- Mention `terraform/environments/aws` as optional cloud migration scaffold

## CI/CD

- CI checks: lint, tests, Terraform validate, Kubernetes schema validation, Docker build
- CD flow: build image, push to GHCR, Trivy scan, deploy with `kubectl` when `KUBE_CONFIG_DATA` is configured

## Observability

- Prometheus scraping of `/metrics`
- Grafana dashboard from `monitoring/grafana/ecommerce-dashboard.json`
- Alert rules: `HighErrorRate`, `HighLatency`, `TaskWriteFailureRate`, `PodCrashLooping`
- Include screenshots from Grafana and Prometheus/Alertmanager

## SLOs and Scaling

- Availability SLO: `>= 99.9%`
- p99 latency SLO: `< 500ms`
- Task write success ratio SLO: `>= 99%`
- HPA min/max replicas and CPU target
- Explain `/work?cpu_iterations=...` as the scaling-demo workload

## Evidence

- GitHub Actions screenshots
- Grafana screenshot
- Alert screenshot
- HPA scaling screenshot
- Load test JSON or Locust summary
