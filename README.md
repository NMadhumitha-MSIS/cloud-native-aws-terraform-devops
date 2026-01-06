# Cloud-Native Web Application (AWS + Terraform + DevOps)

## Overview
This project deploys a production-grade Node.js web application on AWS using Terraform (Infrastructure as Code), Packer-built AMIs, and CI/CD with GitHub Actions. It’s designed to demonstrate scalable, secure, observable cloud deployment patterns.

## Why there are “two orgs”
This work was intentionally split into two parts to simulate real-world engineering:
- **Application Team (Org 1):** owns the Node.js application and app CI
- **Platform/Infra Team (Org 2):** owns Terraform infrastructure and deployment automation

For portfolio clarity, both parts are organized into a single, recruiter-friendly repository structure.

## Repository Structure
- `app/` — Node.js application source code
- `infra/` — Terraform AWS infrastructure (VPC, ALB, ASG, RDS, S3, Route 53, ACM, CloudWatch, KMS/Secrets)
- `packer/` — Packer templates + provisioning scripts for AMI creation
- `.github/workflows/` — CI/CD workflows (Terraform validate/plan, app CI, Packer validate/build)
- `docs/` — architecture notes, runbook steps (to be expanded)
- `assets/` — diagrams/screenshots (to be added)

## Tech Stack
- **Cloud:** AWS (EC2, RDS, S3, ALB, Route 53, CloudWatch, KMS, ACM, Secrets Manager)
- **IaC:** Terraform
- **CI/CD:** GitHub Actions
- **App:** Node.js
- **Image Build:** Packer
- **OS/Scripting:** Linux, Bash

## High-Level Architecture
User → Route 53 → ALB (HTTPS/ACM) → Auto Scaling Group (EC2 running Node.js)  
Data → RDS  
Artifacts/Static → S3  
Monitoring/Logs → CloudWatch  
Secrets/Keys → Secrets Manager + KMS

## How to Run Locally (App)
```bash
cd app
npm install
npm start

## Infrastructure (Terraform)
Note: Do NOT commit .tfstate or .terraform/ files.

cd infra
terraform init
terraform validate
terraform plan
# terraform apply

## CI/CD

Workflows are available under .github/workflows/ for:
- Terraform validation/plan
- App CI checks
- Packer validation/build

## Next Improvements
- Add architecture diagram in assets/
- Add step-by-step deployment runbook in docs/
- Add sanitized example config files (*.example)
- Add screenshots of CloudWatch dashboards/logs
