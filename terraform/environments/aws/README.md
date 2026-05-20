# AWS Environment

This environment is an optional cloud migration path. The local Minikube environment is the primary runnable demo, while this folder documents how the same service can be promoted toward EKS.

## What is already here

- provider definitions
- variables for image, passwords, cluster name, and region
- a backend file ready to switch from local state to S3
- module wiring for the application and monitoring stack
- an `aws-eks` scaffold module for the cluster layer

## What still requires cloud credentials

- uncommenting the EKS module
- uncommenting the S3 backend
- applying the configuration against AWS

## Suggested activation flow

```bash
cd ../../bootstrap
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply

cd ../environments/aws
cp terraform.tfvars.example terraform.tfvars
terraform init -reconfigure
terraform plan
terraform apply
```

After the cluster exists, update kubeconfig:

```bash
aws eks update-kubeconfig --name sre-capstone --region us-east-1
```
