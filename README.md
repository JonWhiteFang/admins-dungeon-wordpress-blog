# AWS Lightsail WordPress Deployment

Production-ready WordPress blog deployment on AWS Lightsail using Infrastructure as Code (CloudFormation). Deploy a secure, optimized WordPress site in minutes with automated backups, SSL/HTTPS, and monitoring.

## Features

- **Automated Deployment**: Single CloudFormation command creates all infrastructure
- **Security Hardened**: SSL/HTTPS, security plugins, firewall rules, and access controls
- **Performance Optimized**: Caching, image optimization, and configurable instance sizing
- **Automated Backups**: Daily snapshots with 7-day retention
- **Monitoring**: CloudWatch metrics and alarms for proactive issue detection
- **Cost Effective**: Starting at ~$14/month for production-ready hosting

## Quick Start

### Prerequisites

- AWS account with billing enabled
- AWS CLI configured with credentials
- Domain name (optional but recommended)
- Email address for SSL notifications

### Deploy in 3 Steps

1. **Clone this repository**
   ```bash
   git clone <repository-url>
   cd lightsail-wordpress-deployment
   ```

2. **Deploy the stack**
   ```bash
   aws cloudformation create-stack \
     --stack-name wordpress-blog-prod \
     --template-body file://lightsail-wordpress.yaml \
     --parameters \
       ParameterKey=InstanceName,ParameterValue=my-wordpress-blog \
       ParameterKey=AdminEmail,ParameterValue=your-email@example.com \
       ParameterKey=DomainName,ParameterValue=yourdomain.com \
     --region eu-west-2
   ```

3. **Wait for completion**
   ```bash
   aws cloudformation wait stack-create-complete \
     --stack-name wordpress-blog-prod \
     --region eu-west-2
   ```

### Get Your Site Details

```bash
aws cloudformation describe-stacks \
  --stack-name wordpress-blog-prod \
  --region eu-west-2 \
  --query "Stacks[0].Outputs"
```

## Architecture

- **Region**: EU (London) - eu-west-2
- **Compute**: AWS Lightsail instances
- **Platform**: Bitnami WordPress Stack (Apache, MySQL, PHP)
- **SSL**: Let's Encrypt via Bitnami bncert-tool
- **Backups**: Automated daily snapshots
- **Monitoring**: CloudWatch metrics and alarms

## Configuration Options

### Instance Sizes

| Plan | vCPU | RAM | Storage | Price/Month |
|------|------|-----|---------|-------------|
| micro_2_0 | 1 | 1GB | 40GB SSD | $5 |
| small_2_0 | 1 | 2GB | 60GB SSD | $10 |
| medium_2_0 | 2 | 4GB | 80GB SSD | $20 |
| large_2_0 | 2 | 8GB | 160GB SSD | $40 |

### Parameters

- **InstanceName**: Unique name for your instance (lowercase, numbers, hyphens)
- **InstancePlan**: Instance size (default: small_2_0)
- **AvailabilityZone**: eu-west-2a, eu-west-2b, or eu-west-2c
- **DomainName**: Your custom domain (optional)
- **AdminEmail**: Email for notifications and SSL
- **EnableAutomaticSnapshots**: Enable daily backups (default: true)

## Post-Deployment Setup

### 1. Retrieve WordPress Admin Password

```bash
# Get SSH command from stack outputs, then:
ssh -i ~/.ssh/LightsailDefaultKey-eu-west-2.pem bitnami@YOUR_STATIC_IP
cat bitnami_application_password
```

### 2. Configure SSL (if using custom domain)

```bash
# After DNS propagation:
ssh -i ~/.ssh/LightsailDefaultKey-eu-west-2.pem bitnami@YOUR_STATIC_IP
sudo /opt/bitnami/bncert-tool
```

### 3. Install Security Plugins

```bash
cd /opt/bitnami/wordpress
sudo -u bitnami wp plugin install wordfence --activate
sudo -u bitnami wp plugin install limit-login-attempts-reloaded --activate
sudo -u bitnami wp plugin install updraftplus --activate
```

### 4. Install Performance Plugins

```bash
sudo -u bitnami wp plugin install wp-super-cache --activate
sudo -u bitnami wp super-cache enable
sudo -u bitnami wp plugin install smush --activate
```

## Management

### Update Stack

```bash
aws cloudformation update-stack \
  --stack-name wordpress-blog-prod \
  --template-body file://lightsail-wordpress.yaml \
  --parameters ParameterKey=InstancePlan,ParameterValue=medium_2_0 \
  --region eu-west-2
```

### Create Manual Backup

```bash
aws lightsail create-instance-snapshot \
  --instance-name my-wordpress-blog \
  --instance-snapshot-name wordpress-backup-$(date +%Y%m%d) \
  --region eu-west-2
```

### Delete Stack

```bash
# Create final backup first
aws lightsail create-instance-snapshot \
  --instance-name my-wordpress-blog \
  --instance-snapshot-name wordpress-final-backup \
  --region eu-west-2

# Then delete
aws cloudformation delete-stack \
  --stack-name wordpress-blog-prod \
  --region eu-west-2
```

## Automation Scripts

Scripts are available in the `scripts/` directory:

- `deploy-stack.sh`: Deploy CloudFormation stack with parameters
- `get-outputs.sh`: Retrieve and display stack outputs
- `configure-ssl.sh`: Configure Let's Encrypt SSL
- `install-security-plugins.sh`: Install security plugins
- `install-caching.sh`: Install and configure caching
- `enable-snapshots.sh`: Enable automatic snapshots
- `daily-health-check.sh`: Check instance health
- `verify-backups.sh`: Verify recent snapshots

## Cost Estimation

**Monthly Costs** (small_2_0 instance):
- Instance: $10
- Static IP: Free (while attached)
- Data transfer: Included
- Snapshots (7 × 60GB): ~$3
- **Total: ~$13/month**

## Security Best Practices

- Change default admin password immediately
- Create new admin user and remove default "user" account
- Keep WordPress, plugins, and themes updated
- Configure Wordfence security plugin
- Restrict SSH access to specific IPs
- Enable HTTPS and force SSL
- Regular backup verification

## Monitoring

CloudWatch metrics are automatically enabled:
- CPU Utilization
- Network In/Out
- Disk Read/Write

Alarms trigger when:
- CPU > 80% for 2 consecutive periods

## Troubleshooting

### Stack Creation Fails

Check CloudFormation events:
```bash
aws cloudformation describe-stack-events \
  --stack-name wordpress-blog-prod \
  --region eu-west-2
```

### WordPress Not Accessible

Verify instance state:
```bash
aws lightsail get-instance \
  --instance-name my-wordpress-blog \
  --region eu-west-2
```

### SSL Certificate Issues

Check DNS propagation:
```bash
nslookup yourdomain.com
```

## Documentation

- [Detailed Deployment Guide](lightsail-wordpress-deployment-prompt.md)
- [Requirements](/.kiro/specs/lightsail-wordpress-deployment/requirements.md)
- [Design Document](/.kiro/specs/lightsail-wordpress-deployment/design.md)
- [Implementation Tasks](/.kiro/specs/lightsail-wordpress-deployment/tasks.md)

## Support

- AWS Lightsail Documentation: https://lightsail.aws.amazon.com/
- WordPress Support: https://wordpress.org/support/
- CloudFormation Documentation: https://docs.aws.amazon.com/cloudformation/

## License

MIT License - See LICENSE file for details

## Contributing

Contributions welcome! Please open an issue or submit a pull request.
