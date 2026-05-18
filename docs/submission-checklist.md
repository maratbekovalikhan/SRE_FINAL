# Submission Checklist

## Repository
- Public GitHub repository pushed
- README is up to date
- Terraform, Kubernetes, monitoring, and scripts are committed

## Before Demo
- Run `make test`
- Run `scripts/start_demo.sh`
- Run `scripts/smoke_test.sh http://127.0.0.1:8000`
- Run `app/.venv/bin/python scripts/load_test.py --url http://127.0.0.1:8000 --requests 300 --concurrency 30`

## Screenshots To Capture
- GitHub Actions successful run
- Grafana dashboard open
- Alertmanager or alert rules visible
- HPA or scaling evidence
- Load test result

## PDF Report
- Architecture diagram or architecture section
- SLOs and SLIs
- Scaling strategy
- Observability stack
- CI/CD explanation
- Screenshots inserted

## Final Safety
- Keep `sre-capstone-restored-backup.zip`
- Keep `sre-capstone 2` untouched as backup
