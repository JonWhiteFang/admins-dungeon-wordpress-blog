# WordPress on AWS Lightsail - Infrastructure as Code

Automated deployment of production-ready WordPress blogs on AWS Lightsail using CloudFormation templates. This solution provides a complete infrastructure setup with security hardening, performance optimization, automated backups, and monitoring.

## Features

- **Automated Deployment**: Single CloudFormation stack creates all infrastructure
- **Security Hardened**: SSL/HTTPS, security plugins, firewall rules, access controls
- **Performance Optimized**: Caching, image optimization, configurable instance sizing
- **Automated Backups**: Daily snapshots with 7-day retention
- **Monitoring**: CloudWatch metrics and alarms for proactive issue detection
- **Cost Effective**: ~$14/month for production-ready hosting

## Project Structure

```
.
├── templates/
│   └── lightsail-wordpress.yaml          # CloudFormation template
├── scripts/
│   ├── deployment/                       # Stack deployment & management
│   │   ├── deploy-stack.sh
│   │   ├── update-stack.sh
│   │   ├── delete-stack.sh
│   │   ├── get-outputs.sh
│   │   ├── export-template.sh
│   │   ├── validate-template.sh
│   │   ├── test-user-data.sh
│   │   └── test-deployment.sh
│   ├── configuration/                    # WordPress configuration
│   │   ├── get-admin-password.sh
│   │   ├── configure-ssl.sh
│   │   └── update-wp-config.sh
│   ├── security/                         # Security hardening
│   │   ├── install-security-plugins.sh
│   │   ├── create-admin-user.sh
│   │   └── update-wordpress.sh
│   ├── performance/                      # Performance optimization
│   │   ├── install-caching.sh
│   │   └── install-redis.sh
│   ├── backup/                           # Backup management
│   │   ├── enable-snapshots.sh
│   │   ├── verify-snapshots.sh
│   │   ├── create-manual-snapshot.sh
│   │   └── verify-backups.sh
│   └── monitoring/                       # Monitoring & health checks
│       ├── enable-monitoring.sh
│       ├── create-alarms.sh
│       └── daily-health-check.sh
├── docs/                                 # Documentation
│   └── lightsail-wordpress-deployment-prompt.md
└── README.md
```

## Prerequisites

- AWS CLI installed and configured
- AWS account with Lightsail access
- SSH key pair created in eu-west-2 region (LightsailDefaultKey-eu-west-2)
- Domain name (optional, for custom domain setup)
- Basic knowledge of AWS, WordPress, and bash scripting

## Quick Start

### 1. Validate Template

```bash
bash scripts/deployment/validate-template.sh
```

### 2. Deploy Stack

Edit `scripts/deployment/deploy-stack.sh` to configure your parameters:
- INSTANCE_NAME
- INSTANCE_PLAN (micro_2_0, small_2_0, medium_2_0, large_2_0)
- ADMIN_EMAIL
- DOMAIN_NAME (optional)

Then deploy:

```bash
bash scripts/deployment/deploy-stack.sh
```

### 3. Get Stack Outputs

```bash
bash scripts/deployment/get-outputs.sh
```

### 4. Retrieve Admin Password

```bash
bash scripts/configuration/get-admin-password.sh
```

### 5. Access WordPress

Navigate to the WordPress admin URL from the stack outputs and log in with:
- Username: `user`
- Password: (retrieved from step 4)

## Deployment Phases

### Phase 1: Infrastructure Setup (5-10 minutes)
- CloudFormation stack creation
- Lightsail instance provisioning
- Static IP allocation
- Firewall configuration
- DNS zone setup (if domain configured)

### Phase 2: WordPress Configuration (10-15 minutes)
- System package updates
- PHP configuration
- WordPress permissions
- SSL certificate setup (if domain configured)

### Phase 3: Security Hardening (5-10 minutes)
- Install security plugins
- Create new admin user
- Remove default user
- Configure security settings

### Phase 4: Performance Optimization (5-10 minutes)
- Install caching plugins
- Configure Redis (optional)
- Optimize images

### Phase 5: Backup & Monitoring (5 minutes)
- Enable automatic snapshots
- Configure CloudWatch alarms
- Verify backup configuration

**Total Deployment Time**: 30-50 minutes

## Post-Deployment Configuration

### Configure SSL Certificate

If using a custom domain:

1. Update DNS nameservers at your registrar (see stack outputs)
2. Wait for DNS propagation (24-48 hours)
3. Run SSL configuration:

```bash
bash scripts/configuration/configure-ssl.sh
```

### Install Security Plugins

```bash
bash scripts/security/install-security-plugins.sh
```

Installed plugins:
- Wordfence Security
- Limit Login Attempts Reloaded
- UpdraftPlus Backup

### Install Caching Plugins

```bash
bash scripts/performance/install-caching.sh
```

Installed plugins:
- WP Super Cache
- Smush Image Optimization

### Install Redis (Optional)

```bash
bash scripts/performance/install-redis.sh
```

### Create New Admin User

```bash
bash scripts/security/create-admin-user.sh
```

### Enable Automatic Snapshots

```bash
bash scripts/backup/enable-snapshots.sh
```

### Configure Monitoring Alarms

```bash
bash scripts/monitoring/create-alarms.sh
```

## Maintenance Scripts

### Update WordPress

```bash
bash scripts/security/update-wordpress.sh
```

Updates WordPress core, all plugins, and themes.

### Daily Health Check

```bash
bash scripts/monitoring/daily-health-check.sh
```

Checks instance state, CPU utilization, and network traffic.

### Verify Backups

```bash
bash scripts/backup/verify-backups.sh
```

Lists recent snapshots and verifies backup status.

### Create Manual Snapshot

```bash
bash scripts/backup/create-manual-snapshot.sh
```

### Update Stack

```bash
bash scripts/deployment/update-stack.sh
```

### Export Template

```bash
bash scripts/deployment/export-template.sh
```

### Delete Stack

```bash
bash scripts/deployment/delete-stack.sh
```

Creates final backup before deletion.

## Architecture

### Components

- **Lightsail Instance**: WordPress (Bitnami stack) on Ubuntu
- **Static IP**: Persistent IP address for the instance
- **DNS Zone**: Lightsail DNS for custom domain (optional)
- **SSL Certificate**: Let's Encrypt via bncert-tool (optional)
- **Firewall**: Ports 22 (SSH), 80 (HTTP), 443 (HTTPS)
- **Snapshots**: Automatic daily backups with 7-day retention
- **CloudWatch**: Metrics and alarms for monitoring

### Instance Sizing

| Plan | vCPUs | RAM | Storage | Transfer | Price/Month |
|------|-------|-----|---------|----------|-------------|
| micro_2_0 | 1 | 1 GB | 40 GB SSD | 2 TB | $7 |
| small_2_0 | 1 | 2 GB | 60 GB SSD | 3 TB | $14 |
| medium_2_0 | 2 | 4 GB | 80 GB SSD | 4 TB | $28 |
| large_2_0 | 2 | 8 GB | 160 GB SSD | 5 TB | $56 |

**Recommended**: small_2_0 for production blogs

## Cost Estimation

### Monthly Costs (small_2_0 plan)
- Lightsail instance: $14.00
- Static IP: $0.00 (included)
- DNS zone: $0.50
- Snapshots (7 days): ~$0.50
- Data transfer: $0.00 (3 TB included)

**Total**: ~$15/month

## Troubleshooting

### Stack Creation Failed

Check CloudFormation events:
```bash
aws cloudformation describe-stack-events --stack-name wordpress-blog-prod --region eu-west-2
```

### WordPress Not Accessible

1. Check instance state:
```bash
aws lightsail get-instance-state --instance-name wordpress-blog-prod-eu-west-2 --region eu-west-2
```

2. Check initialization logs:
```bash
ssh -i ~/.ssh/LightsailDefaultKey-eu-west-2.pem bitnami@<IP> 'cat /var/log/wordpress-init.log'
```

### SSL Certificate Issues

1. Verify DNS propagation:
```bash
dig example.com
```

2. Check bncert-tool logs:
```bash
ssh -i ~/.ssh/LightsailDefaultKey-eu-west-2.pem bitnami@<IP> 'sudo cat /opt/bitnami/letsencrypt/letsencrypt.log'
```

### High CPU Usage

1. Check WordPress plugins
2. Review CloudWatch metrics
3. Consider upgrading instance plan

### Backup Failures

1. Verify snapshot configuration:
```bash
bash scripts/backup/verify-snapshots.sh
```

2. Check Lightsail service status

## MCP Server Usage

This project uses MCP (Model Context Protocol) servers for enhanced AWS documentation access:

### Configured Servers

- **aws-docs**: AWS documentation search and retrieval
- **aws-core**: AWS expert guidance and prompt understanding

### Example Queries

```
# Search AWS documentation
"How do I configure Lightsail firewall rules?"

# Get CloudFormation guidance
"What are best practices for CloudFormation templates?"

# Troubleshoot issues
"Why is my Lightsail instance not accessible?"
```

## Security Best Practices

1. **Change default admin credentials** immediately after deployment
2. **Enable automatic updates** for WordPress core and plugins
3. **Configure Wordfence** firewall and malware scanning
4. **Limit login attempts** to prevent brute force attacks
5. **Regular backups** - verify snapshots weekly
6. **Monitor security logs** in WordPress admin
7. **Keep plugins minimal** - only install what you need
8. **Use strong passwords** for all accounts
9. **Enable two-factor authentication** (via plugin)
10. **Regular security audits** using Wordfence scans

## Performance Optimization

1. **Enable WP Super Cache** for page caching
2. **Configure Redis** for object caching
3. **Optimize images** with Smush
4. **Use CDN** for static assets (optional)
5. **Minimize plugins** - deactivate unused plugins
6. **Database optimization** - use WP-Optimize plugin
7. **Monitor performance** with CloudWatch metrics
8. **Upgrade instance** if consistently high CPU usage

## Support

For issues or questions:
1. Check troubleshooting section above
2. Review AWS Lightsail documentation
3. Check WordPress Bitnami documentation
4. Review CloudFormation stack events

## License

This project is provided as-is for educational and production use.

## Contributing

Contributions welcome! Please test changes thoroughly before submitting.
