---
inclusion: always
---

# Project Structure & Conventions

## Directory Layout

```
templates/lightsail-wordpress.yaml    # CloudFormation IaC (single source of truth)
scripts/
  ├── deployment/                     # Stack lifecycle (deploy, update, delete, validate)
  ├── configuration/                  # WordPress setup (SSL, wp-config, passwords)
  ├── security/                       # Hardening (plugins, users, updates)
  ├── performance/                    # Optimization (caching, Redis)
  ├── backup/                         # Snapshot management
  └── monitoring/                     # Health checks and alarms
docs/                                 # Deployment guides and documentation
.kiro/
  ├── specs/lightsail-wordpress-deployment/  # Requirements, design, tasks
  └── steering/                       # AI guidance documents
```

## File Modification Rules

**CloudFormation Template** (`templates/lightsail-wordpress.yaml`):
- Single source of truth for infrastructure
- All changes must maintain idempotency
- Validate with `aws cloudformation validate-template` before committing
- Document cost implications of resource changes

**Bash Scripts** (`scripts/**/*.sh`):
- Must be idempotent (safe to re-run)
- Include error handling with clear messages
- Validate syntax with `bash -n script.sh`
- Use `set -euo pipefail` at script start
- Provide informative output for operations

## Naming Conventions

**CloudFormation Resources**:
- Stack: `wordpress-blog-prod`
- Instance: `wordpress-blog-prod-us-east-1`
- Pattern: `{InstanceName}-{resource-type}`

**Scripts**:
- Format: `{action}-{target}.sh` (kebab-case)
- Actions: `deploy-`, `install-`, `enable-`, `verify-`, `create-`, `update-`, `get-`

**Snapshots**:
- Manual: `wordpress-{purpose}-YYYYMMDD`
- Automatic: Lightsail-generated timestamps

## Critical Paths

**Instance Locations** (Bitnami WordPress on Lightsail):
- WordPress root: `/opt/bitnami/wordpress/`
- Config: `/opt/bitnami/wordpress/wp-config.php`
- Admin password: `/home/bitnami/bitnami_application_password`
- Logs: `/var/log/wordpress-init.log`, `/var/log/cloud-init-output.log`
- PHP config: `/opt/bitnami/php/etc/php.ini`
- Apache config: `/opt/bitnami/apache2/conf/`
- Control script: `/opt/bitnami/ctlscript.sh`

**AWS Configuration**:
- Region: `us-east-1` (N. Virginia)
- AZs: `us-east-1a`, `us-east-1b`, `us-east-1c`, `us-east-1d`, `us-east-1e`, `us-east-1f`

## Script Organization by Purpose

**Deployment** - CloudFormation stack operations
**Configuration** - WordPress and SSL setup
**Security** - Wordfence, login limits, user management
**Performance** - WP Super Cache, Redis, image optimization
**Backup** - Daily snapshots (7-day retention)
**Monitoring** - CloudWatch metrics and alarms

## Code Style

**Bash Scripts**:
- Use `#!/usr/bin/env bash` shebang
- Set strict mode: `set -euo pipefail`
- Validate required tools at script start
- Use descriptive variable names in UPPER_CASE for constants
- Include usage/help functions
- Exit codes: 0 (success), 1 (error), 2 (usage error)

**CloudFormation**:
- YAML format (not JSON)
- Descriptive resource names
- Include comprehensive Outputs section
- Use Parameters for configurable values
- Add Metadata for documentation

## When Modifying This Project

1. **Infrastructure changes**: Update CloudFormation template first, then scripts
2. **New scripts**: Follow naming conventions, make idempotent, add to appropriate directory
3. **Security changes**: Default to secure; make insecure options explicit opt-ins
4. **Testing**: Validate templates and test scripts against actual AWS resources
5. **Documentation**: Update outputs and next steps for user-facing changes
