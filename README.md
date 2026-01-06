# Cloud-Native Web Application (AWS + Terraform + DevOps)

## Overview
Built and deployed a production-grade Node.js web application on AWS using Infrastructure as Code (Terraform) and an automated CI/CD pipeline (GitHub Actions). The setup supports scalability, security best practices, and observability.

## What I Built
- Provisioned AWS infrastructure with Terraform (20+ resources)
- Deployed a Node.js web application behind a Load Balancer (ALB)
- Automated CI/CD with GitHub Actions
- Built custom AMIs using Packer
- Implemented monitoring/observability using CloudWatch
- Secured credentials and encryption using AWS KMS and Secrets Manager
- Configured HTTPS using ACM and DNS routing using Route 53
- Designed for high availability with Auto Scaling

## Tech Stack
- **Cloud:** AWS (EC2, RDS, S3, ALB, Route 53, CloudWatch, KMS, ACM, Secrets Manager)
- **IaC:** Terraform
- **CI/CD:** GitHub Actions
- **App:** Node.js
- **Image Build:** Packer
- **OS/Scripting:** Linux, Bash

## Architecture (High Level)
User → Route 53 → ALB (HTTPS/ACM) → Auto Scaling Group (EC2 running Node.js)  
Data → RDS  
Static/Artifacts → S3  
Monitoring/Logs → CloudWatch  
Secrets/Keys → Secrets Manager + KMS

## Project Deliverables
- Infrastructure as Code (Terraform)
- CI/CD workflow (GitHub Actions)
- Packer template for AMI creation
- Deployment-ready Node.js app

## Project Status
- Code: In progress / to be uploaded
- Documentation: In progress

## Next Improvements
- Add diagram + screenshots in `/assets`
- Add runbook steps in `/docs`
- Add cost estimation and guardrails (budgets/alerts)
