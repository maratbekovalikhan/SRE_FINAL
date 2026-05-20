# GitHub Setup

## Repository Settings

- Make the repository public
- Enable GitHub Actions
- Set workflow permissions to `Read and write permissions`

## Required Secrets

### Optional for auto-deploy

`KUBE_CONFIG_DATA`

- Value: base64-encoded kubeconfig for the target Kubernetes cluster
- Example:

```bash
base64 -i ~/.kube/config | pbcopy
```

Without this secret, CI still works and CD still publishes images to GHCR, but the deploy job is skipped.

## GHCR

The workflows use `${{ secrets.GITHUB_TOKEN }}` for GHCR login.

After the first publish:

1. Open your GitHub profile
2. Go to `Packages`
3. Open the package for this repository
4. Make it public if you want unauthenticated pulls

## What To Commit

- `.github/workflows/*`
- `terraform.tfvars.example`
- `.terraform.lock.hcl`
- Kubernetes manifests
- Monitoring configs

## What Not To Commit

- `.env`
- `terraform.tfvars`
- `.terraform/`
- `*.tfstate`
- real kubeconfigs or cluster credentials
