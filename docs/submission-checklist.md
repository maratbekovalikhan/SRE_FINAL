# Submission Checklist

## Repository

- Public GitHub repository
- Updated `README.md`
- Terraform, Kubernetes, monitoring, CI/CD, and scripts committed
- `.terraform.lock.hcl` committed for reproducibility

## Before Demo

- Run `make test`
- Run `./scripts/start_demo.sh`
- Run `./scripts/smoke_test.sh http://127.0.0.1:8000`
- Run `python3 scripts/load_test.py --url http://127.0.0.1:8000 --requests 300 --concurrency 30`
- If demonstrating HPA, run Locust or repeated `/work?cpu_iterations=...` traffic

## Screenshots To Capture

- Successful CI workflow run
- Successful CD workflow run
- Grafana dashboard with SLI panels visible
- Alertmanager page or Prometheus alerts page with active/firing alert
- `kubectl get hpa -n task-api -w` or dashboard view showing replicas scaling
- Load test summary output

## PDF Report Must Include

- Architecture overview
- Terraform and state-management explanation
- CI/CD workflow explanation
- SLOs and alert rules
- Auto-scaling strategy
- Evidence screenshots

## Evidence Folder

- Refresh `test-output.txt`
- Refresh `smoke-test.txt`
- Refresh `load-test-summary.json`
- Refresh `docker-compose-config.txt`
- Add manual screenshots as `.png` files before final submission
