# Defense Notes

## 30-Second Intro
This project prepares a small e-commerce service for production readiness using Terraform, Kubernetes, CI/CD, observability, and SRE practices. The same repository supports both an AWS EKS deployment path and a local demo path for verification.

## What To Show First
1. `scripts/start_demo.sh`
2. Open `http://127.0.0.1:8000/health`, `/products`, and `/metrics`
3. Run `make test`
4. Run `app/.venv/bin/python scripts/load_test.py --url http://127.0.0.1:8000 --requests 300 --concurrency 30`
5. Show Terraform and GitHub Actions files

## If Asked About SLOs
- Availability target: 99.9%
- Latency target: p99 below 500 ms
- Business metric: successful order rate
- Alert rules map directly to these SLOs

## If Asked About Autoscaling
- HPA in `k8s/deployment.yaml`
- CPU and memory thresholds configured
- Local app can simulate CPU work with `CPU_WORK_ITERATIONS` to create realistic pressure
- In EKS, metrics-server is required and installed via `scripts/install_metrics_server.sh`

## If Asked About Observability
- App exports Prometheus metrics from `/metrics`
- Prometheus discovers the app through ServiceMonitor in Kubernetes
- Grafana dashboard visualizes request rate, error rate, p99 latency, and successful order rate
- Alertmanager is configured for routing and grouping alerts

## If Asked Why There Is A Local Demo Path
- It provides a reliable verification mode when cloud resources or credentials are unavailable
- It proves the service, metrics, and load testing workflows end-to-end before EKS deployment
