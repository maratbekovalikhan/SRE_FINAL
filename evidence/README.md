# Evidence Folder

This folder is for submission artifacts collected from local validation and demo runs.

Recommended command:

```bash
cd /Users/arslanmaratbekov/sre-final-project/sre-capstone
scripts/collect_local_evidence.sh
```

Expected outputs:
- `test-output.txt`
- `start-demo.txt`
- `smoke-test.txt`
- `load-test-summary.json`
- `docker-compose-config.txt`
- `k8s-status.txt`
- `hpa-status.txt`
- `k8s-top-pods.txt`

Optional Kubernetes autoscaling demo artifacts:

- `hpa-before.txt`
- `hpa-after.txt`
- `hpa-scaling.txt`
- `hpa-load-rounds.txt`
- `hpa-port-forward.log`

Manual screenshots should also be saved here before submission:

- `ci-success.png`
- `cd-success.png`
- `grafana-dashboard.png`
- `alertmanager-or-prometheus-alerts.png`
- `hpa-scaling.png`

If any text files in this directory were created before the latest code changes, regenerate them before submission.

Useful commands:

```bash
cd /Users/arslanmaratbekov/sre-final-project/sre-capstone
scripts/collect_k8s_evidence.sh
scripts/hpa_demo.sh
```
