# SRE Capstone: Task Manager API

![CI](https://github.com/maratbekovalikhan/sre-capstone/actions/workflows/ci.yml/badge.svg)
![CD](https://github.com/maratbekovalikhan/sre-capstone/actions/workflows/cd.yml/badge.svg)

Production-readiness project for an SRE capstone. The service is a FastAPI-based task manager with PostgreSQL, Redis, Prometheus, Grafana, Alertmanager, Terraform, Kubernetes, Docker, and GitHub Actions.

## What this repository demonstrates

- **Infrastructure as Code:** Terraform modules for application resources, monitoring, HPA, and optional AWS state bootstrap
- **CI/CD:** GitHub Actions for linting, tests, Docker image publishing to GHCR, and cluster deployment through `kubectl`
- **Observability:** Prometheus scraping, Grafana dashboard provisioning, Alertmanager routing, and PrometheusRule alerts
- **SRE Operations:** health/readiness probes, SLO-backed alerts, HPA, and load-testing with Locust or the built-in workload script

## Quick Start

### Local demo stack

```bash
git clone <repo-url>
cd sre-capstone
./scripts/start_demo.sh
```

Services:

| Service | URL |
|---------|-----|
| API Docs | http://127.0.0.1:8000/docs |
| Prometheus | http://127.0.0.1:9090 |
| Grafana | http://127.0.0.1:3000 |
| Alertmanager | http://127.0.0.1:9093 |

Grafana credentials: `admin / admin`

Stop the stack:

```bash
./scripts/stop_demo.sh
```

### Smoke test

```bash
./scripts/smoke_test.sh http://127.0.0.1:8000
```

### Built-in load test

```bash
python3 scripts/load_test.py \
  --url http://127.0.0.1:8000 \
  --path /work?delay=15\&cpu_iterations=60000 \
  --requests 300 \
  --concurrency 30
```

### Locust load test

```bash
locust -f locust/locustfile.py --host=http://127.0.0.1:8000 \
  --users 100 --spawn-rate 10 --run-time 5m --headless
```

## API

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/` | Service info |
| `GET` | `/health` | Liveness probe |
| `GET` | `/ready` | Readiness probe for DB and Redis |
| `POST` | `/tasks` | Create task |
| `GET` | `/tasks` | List tasks |
| `GET` | `/tasks/{id}` | Read one task |
| `PUT` | `/tasks/{id}` | Update task |
| `DELETE` | `/tasks/{id}` | Delete task |
| `GET` | `/work` | Synthetic workload for latency/error/HPA demos |
| `GET` | `/metrics` | Prometheus metrics |

## Terraform

Main Terraform paths:

- `terraform/environments/local` for Minikube
- `terraform/environments/aws` for the optional AWS/EKS scaffold
- `terraform/bootstrap` for optional S3 + DynamoDB remote-state bootstrap

Local deployment:

```bash
./scripts/setup.sh
```

Useful evidence helpers:

```bash
./scripts/collect_local_evidence.sh
./scripts/collect_k8s_evidence.sh
./scripts/hpa_demo.sh
```

Redeploy a specific image:

```bash
./scripts/deploy.sh ghcr.io/<owner>/<repo>:latest
```

Cleanup:

```bash
./scripts/teardown.sh
```

## CI/CD

### CI

`/.github/workflows/ci.yml` validates:

- Python lint and formatting
- pytest test suite
- Terraform formatting and validation
- Kubernetes manifest schema checks
- Docker buildability

### CD

`/.github/workflows/cd.yml` performs:

- Docker build and push to GHCR
- Trivy image scan
- Automatic deployment to a Kubernetes cluster when `KUBE_CONFIG_DATA` is configured as a GitHub Actions secret

`KUBE_CONFIG_DATA` should contain a base64-encoded kubeconfig:

```bash
base64 -i ~/.kube/config | pbcopy
```

## SLOs

| SLI | Target SLO | Alert |
|-----|------------|-------|
| Availability | `>= 99.9%` | `HighErrorRate` |
| p99 latency | `< 500ms` | `HighLatency` |
| Task write success ratio | `>= 99%` | `TaskWriteFailureRate` |

## Project Layout

```text
app/                    FastAPI application and metrics
tests/                  pytest suite
k8s/                    Kubernetes manifests, including HPA
terraform/              Terraform environments, modules, and bootstrap
monitoring/             Prometheus, Grafana, and Alertmanager configs
locust/                 Locust load-test scenario
scripts/                Demo, deploy, teardown, and evidence collection scripts
docs/                   Report, checklist, and defense notes
evidence/               Generated logs plus manual screenshots for submission
```

## Submission checklist

Before submitting:

1. Run `./scripts/start_demo.sh`
2. Run `make test`
3. Run `./scripts/smoke_test.sh`
4. Run `python3 scripts/load_test.py ...`
5. Capture screenshots for GitHub Actions, Grafana, Alertmanager, and HPA
6. Insert those screenshots into the PDF report
