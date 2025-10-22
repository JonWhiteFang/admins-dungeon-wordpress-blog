# Project Organization

This document describes the reorganized structure of the WordPress on AWS Lightsail project.

## Directory Structure

### `/templates`
Contains CloudFormation infrastructure templates.
- `lightsail-wordpress.yaml` - Main CloudFormation template for WordPress deployment

### `/scripts`
Organized automation scripts by functional category:

#### `/scripts/deployment`
Stack deployment and management scripts:
- `deploy-stack.sh` - Deploy new CloudFormation stack
- `update-stack.sh` - Update existing stack
- `delete-stack.sh` - Delete stack with final backup
- `get-outputs.sh` - Retrieve stack outputs
- `export-template.sh` - Export current template
- `validate-template.sh` - Validate CloudFormation template
- `test-user-data.sh` - Test user data script syntax
- `test-deployment.sh` - End-to-end deployment testing

#### `/scripts/configuration`
WordPress configuration scripts:
- `get-admin-password.sh` - Retrieve WordPress admin password
- `configure-ssl.sh` - Configure Let's Encrypt SSL certificate
- `update-wp-config.sh` - Update WordPress configuration

#### `/scripts/security`
Security hardening scripts:
- `install-security-plugins.sh` - Install Wordfence, Limit Login Attempts, UpdraftPlus
- `create-admin-user.sh` - Create new admin and remove default user
- `update-wordpress.sh` - Update WordPress core, plugins, and themes

#### `/scripts/performance`
Performance optimization scripts:
- `install-caching.sh` - Install WP Super Cache and Smush
- `install-redis.sh` - Install and configure Redis object caching

#### `/scripts/backup`
Backup management scripts:
- `enable-snapshots.sh` - Enable automatic daily snapshots
- `verify-snapshots.sh` - Verify snapshot configuration
- `create-manual-snapshot.sh` - Create manual snapshot
- `verify-backups.sh` - Verify recent backups

#### `/scripts/monitoring`
Monitoring and health check scripts:
- `enable-monitoring.sh` - Verify CloudWatch monitoring
- `create-alarms.sh` - Configure CloudWatch alarms
- `daily-health-check.sh` - Daily instance health check

### `/docs`
Project documentation:
- `lightsail-wordpress-deployment-prompt.md` - Original deployment guide
- `PROJECT_ORGANIZATION.md` - This file

### `/.kiro`
Kiro IDE configuration:
- `/settings` - MCP server configuration
- `/specs` - Project specifications (requirements, design, tasks)
- `/steering` - Project guidelines and conventions

## Benefits of This Organization

1. **Clear Separation of Concerns**: Each directory has a specific purpose
2. **Easy Navigation**: Scripts are grouped by functionality
3. **Scalability**: Easy to add new scripts in appropriate categories
4. **Maintainability**: Clear structure makes updates straightforward
5. **Documentation**: Self-documenting through directory names

## Usage

All script paths in documentation and other scripts have been updated to reflect the new structure. For example:

```bash
# Old path
bash scripts/deploy-stack.sh

# New path
bash scripts/deployment/deploy-stack.sh
```

## Migration Notes

- CloudFormation template moved from root to `templates/`
- All scripts moved from flat `scripts/` to categorized subdirectories
- Original deployment guide moved to `docs/`
- All script references updated to new paths
- README.md updated with new structure
- structure.md steering file updated
