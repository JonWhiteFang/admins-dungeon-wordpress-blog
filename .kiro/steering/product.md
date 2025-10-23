---
inclusion: always
---

# Product Context

## What This Project Does

Automated IaC solution for deploying production-ready WordPress blogs on AWS Lightsail using CloudFormation. Single-command deployment creates fully configured instances in us-east-1 with security, performance, backups, and monitoring built-in.

## Core Capabilities

- **One-Command Deployment**: CloudFormation stack provisions all infrastructure
- **Security First**: SSL/HTTPS, Wordfence, firewall rules, limited login attempts
- **Performance Built-In**: WP Super Cache, Redis, image optimization, tuned PHP settings
- **Automated Backups**: Daily snapshots (7-day retention)
- **Proactive Monitoring**: CloudWatch metrics and alarms
- **Cost Predictable**: ~$14/month for production hosting

## Design Principles

1. **Reproducibility**: All infrastructure defined in version-controlled templates
2. **Minimal Manual Steps**: Automation scripts handle post-deployment configuration
3. **Production Ready**: Security and performance optimizations applied by default
4. **Idempotent Operations**: Scripts can be safely re-run
5. **Clear Outputs**: Stack outputs provide all necessary connection details and next steps

## User Expectations

Target users are DevOps engineers and sysadmins who:
- Value infrastructure as code over manual configuration
- Need consistent, repeatable WordPress deployments
- Require production-grade security and performance from day one
- Want automated operational tasks (backups, monitoring, updates)

## When Working on This Project

- Maintain CloudFormation template as single source of truth for infrastructure
- Keep scripts idempotent and well-documented with clear error messages
- Default to secure configurations; make insecure options explicit opt-ins
- Provide clear outputs and next steps after operations
- Test all changes against actual AWS resources, not just syntax validation
- Document cost implications of infrastructure changes
