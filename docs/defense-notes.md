# Defense Notes

## 30-Second Intro

This project prepares a FastAPI task manager service for a Production Readiness Review using Terraform, Kubernetes, Docker, GitHub Actions, Prometheus, Grafana, Alertmanager, HPA, and automated load testing.

## Demo Order

1. Show the repository structure and `README.md`
2. Run `./scripts/start_demo.sh`
3. Open `/health`, `/ready`, `/docs`, and `/metrics`
4. Open Grafana and Prometheus
5. Run `./scripts/smoke_test.sh`
6. Run `python3 scripts/load_test.py --url http://127.0.0.1:8000 --requests 300 --concurrency 30`
7. If asked about scaling, run Locust against `/work?cpu_iterations=...`
8. Show Terraform and the GitHub Actions workflows

## Key Talking Points

- **IaC:** Terraform creates the namespace, secrets, PostgreSQL, Redis, app deployment, ingress, monitoring stack, and HPA in the local environment.
- **State management:** Local environment uses a local backend; `terraform/bootstrap` provides optional S3 + DynamoDB state infrastructure for AWS.
- **CI/CD:** CI validates code and infrastructure; CD publishes images to GHCR and can deploy automatically when `KUBE_CONFIG_DATA` is configured.
- **Observability:** Prometheus scrapes `/metrics`, Grafana visualizes SLOs, and Alertmanager receives rule output.
- **SLOs:** Availability `>= 99.9%`, p99 latency `< 500ms`, task-write success ratio `>= 99%`.
- **Scaling:** HPA targets 70% CPU and the `/work` endpoint can generate realistic CPU pressure for a live scaling demo.

## Common Questions

### Why keep both Terraform and raw Kubernetes manifests?

Terraform is the primary deployment path for reproducibility. Raw manifests are also kept so CI/CD can apply app updates to a running cluster without re-running the full Terraform stack every time.

### Why use `/work` in load testing?

It gives a controlled way to inject latency, failures, and CPU load without breaking the CRUD API or mutating production-like business data.

### What would you improve next?

- Replace in-repo demo secrets with External Secrets or Vault
- Activate the AWS EKS scaffold fully when cloud credentials are available
- Add screenshot evidence and a final PDF export for submission
