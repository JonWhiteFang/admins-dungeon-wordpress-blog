# AWS Lightsail WordPress Blog Deployment with CloudFormation and MCP

## Objective
Deploy and manage a production-ready WordPress blog on AWS Lightsail in the EU (London) region using Infrastructure as Code (CloudFormation) and MCP servers for automated operations, monitoring, and documentation access.

## Prerequisites
- Active AWS account with billing enabled
- AWS CLI configured with appropriate credentials
- Domain name (optional but recommended for production use)
- Email address for SSL certificate notifications
- MCP servers configured in Kiro (AWS Documentation, AWS Core)

## Architecture Overview

This deployment uses:
- **CloudFormation**: Infrastructure as Code for reproducible deployments
- **AWS Lightsail**: Managed WordPress hosting platform
- **MCP Servers**: Automated documentation access and AWS expertise
- **Static IP**: Persistent IP address for domain configuration
- **Let's Encrypt**: Free SSL/TLS certificates

## MCP Server Configuration

### Required MCP Servers

Add these to your `.kiro/settings/mcp.json`:

```json
{
  "mcpServers": {
    "aws-docs": {
      "command": "uvx",
      "args": ["awslabs.aws-documentation-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      },
      "disabled": false,
      "autoApprove": ["search_documentation", "read_documentation"]
    },
    "aws-core": {
      "command": "uvx",
      "args": ["mcp-aws-core"],
      "disabled": false,
      "autoApprove": ["prompt_understanding"]
    }
  }
}
```

## CloudFormation Template

### Main Template: `lightsail-wordpress.yaml`

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: 'AWS Lightsail WordPress Blog Deployment - Production Ready'

Parameters:
  InstanceName:
    Type: String
    Default: wordpress-blog-prod-us-east-1
    Description: Name for the Lightsail WordPress instance
    AllowedPattern: ^[a-z0-9-]+$
    ConstraintDescription: Must contain only lowercase letters, numbers, and hyphens

  InstancePlan:
    Type: String
    Default: small_2_0
    Description: Lightsail instance bundle size
    AllowedValues:
      - micro_2_0      # $5/month - 1GB RAM, 1 vCPU, 40GB SSD
      - small_2_0      # $10/month - 2GB RAM, 1 vCPU, 60GB SSD
      - medium_2_0     # $20/month - 4GB RAM, 2 vCPU, 80GB SSD
      - large_2_0      # $40/month - 8GB RAM, 2 vCPU, 160GB SSD

  AvailabilityZone:
    Type: String
    Default: us-east-1a
    Description: Availability zone for the instance
    AllowedValues:
      - us-east-1a
      - us-east-1b
      - us-east-1c

  DomainName:
    Type: String
    Default: ''
    Description: (Optional) Your domain name for the WordPress site

  AdminEmail:
    Type: String
    Description: Email address for WordPress admin and SSL notifications
    AllowedPattern: ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$

  EnableAutomaticSnapshots:
    Type: String
    Default: 'true'
    Description: Enable automatic daily snapshots
    AllowedValues:
      - 'true'
      - 'false'

Conditions:
  HasDomain: !Not [!Equals [!Ref DomainName, '']]
  EnableSnapshots: !Equals [!Ref EnableAutomaticSnapshots, 'true']

Resources:
  # WordPress Instance
  WordPressInstance:
    Type: AWS::Lightsail::Instance
    Properties:
      InstanceName: !Ref InstanceName
      AvailabilityZone: !Ref AvailabilityZone
      BlueprintId: wordpress
      BundleId: !Ref InstancePlan
      Tags:
        - Key: Environment
          Value: Production
        - Key: Application
          Value: WordPress-Blog
        - Key: ManagedBy
          Value: CloudFormation
        - Key: Region
          Value: us-east-1
      UserData: !Sub |
        #!/bin/bash
        # Wait for Bitnami to complete initialization
        sleep 60
        
        # Update system packages
        sudo apt-get update
        sudo apt-get upgrade -y
        
        # Configure WordPress settings
        cd /opt/bitnami/wordpress
        
        # Set proper permissions
        sudo chown -R bitnami:daemon /opt/bitnami/wordpress
        sudo find /opt/bitnami/wordpress -type d -exec chmod 755 {} \;
        sudo find /opt/bitnami/wordpress -type f -exec chmod 644 {} \;
        
        # Configure PHP settings for better performance
        sudo sed -i 's/memory_limit = .*/memory_limit = 256M/' /opt/bitnami/php/etc/php.ini
        sudo sed -i 's/upload_max_filesize = .*/upload_max_filesize = 64M/' /opt/bitnami/php/etc/php.ini
        sudo sed -i 's/post_max_size = .*/post_max_size = 64M/' /opt/bitnami/php/etc/php.ini
        sudo sed -i 's/max_execution_time = .*/max_execution_time = 300/' /opt/bitnami/php/etc/php.ini
        
        # Restart services
        sudo /opt/bitnami/ctlscript.sh restart apache
        sudo /opt/bitnami/ctlscript.sh restart php-fpm
        
        # Create backup directory
        sudo mkdir -p /opt/bitnami/backups
        sudo chown bitnami:daemon /opt/bitnami/backups
        
        # Log completion
        echo "WordPress initialization completed at $(date)" >> /var/log/wordpress-init.log

  # Static IP
  StaticIP:
    Type: AWS::Lightsail::StaticIp
    Properties:
      StaticIpName: !Sub '${InstanceName}-static-ip'
      AttachedTo: !Ref WordPressInstance

  # Firewall Rules
  InstanceFirewall:
    Type: AWS::Lightsail::Instance
    DependsOn: WordPressInstance
    Properties:
      InstanceName: !Ref InstanceName
      Networking:
        Ports:
          - FromPort: 22
            ToPort: 22
            Protocol: tcp
            Cidrs:
              - 0.0.0.0/0  # Restrict this to your IP in production
            CidrListAliases: []
          - FromPort: 80
            ToPort: 80
            Protocol: tcp
            Cidrs:
              - 0.0.0.0/0
            CidrListAliases: []
          - FromPort: 443
            ToPort: 443
            Protocol: tcp
            Cidrs:
              - 0.0.0.0/0
            CidrListAliases: []

  # DNS Zone (if domain provided)
  DNSZone:
    Type: AWS::Lightsail::Domain
    Condition: HasDomain
    Properties:
      DomainName: !Ref DomainName
      DomainEntries:
        - Name: !Ref DomainName
          Type: A
          Target: !GetAtt StaticIP.IpAddress
        - Name: !Sub 'www.${DomainName}'
          Type: A
          Target: !GetAtt StaticIP.IpAddress

  # SSL Certificate (if domain provided)
  SSLCertificate:
    Type: AWS::Lightsail::Certificate
    Condition: HasDomain
    Properties:
      CertificateName: !Sub '${InstanceName}-ssl-cert'
      DomainName: !Ref DomainName
      SubjectAlternativeNames:
        - !Sub 'www.${DomainName}'
      Tags:
        - Key: ManagedBy
          Value: CloudFormation

Outputs:
  InstanceName:
    Description: Name of the WordPress instance
    Value: !Ref InstanceName
    Export:
      Name: !Sub '${AWS::StackName}-InstanceName'

  StaticIPAddress:
    Description: Static IP address for the WordPress site
    Value: !GetAtt StaticIP.IpAddress
    Export:
      Name: !Sub '${AWS::StackName}-StaticIP'

  WordPressURL:
    Description: URL to access WordPress site
    Value: !Sub 'http://${StaticIP.IpAddress}'

  WordPressAdminURL:
    Description: URL to access WordPress admin panel
    Value: !Sub 'http://${StaticIP.IpAddress}/wp-admin'

  SSHCommand:
    Description: SSH command to connect to the instance
    Value: !Sub 'ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@${StaticIP.IpAddress}'

  DomainNameServers:
    Condition: HasDomain
    Description: Lightsail nameservers for domain configuration
    Value: 'ns-1.awsdns.com, ns-2.awsdns.co.uk, ns-3.awsdns.org, ns-4.awsdns.net'

  NextSteps:
    Description: Next steps after deployment
    Value: |
      1. Retrieve WordPress admin password: ssh to instance and run 'cat bitnami_application_password'
      2. Access WordPress admin at the AdminURL
      3. Change default admin password immediately
      4. If using custom domain, update nameservers at your registrar
      5. Configure SSL certificate after DNS propagation
```

## Deployment Instructions

### Phase 1: Pre-Deployment Setup (5 minutes)

1. **Verify AWS CLI Configuration**
   ```bash
   aws configure list
   aws lightsail get-regions --query "regions[?name=='us-east-1']"
   ```

2. **Use MCP AWS Core for Guidance**
   - Ask Kiro: "What are the best practices for Lightsail WordPress deployment?"
   - MCP will provide AWS expert guidance automatically

3. **Search AWS Documentation**
   - Ask Kiro: "Search AWS Lightsail CloudFormation documentation"
   - MCP will fetch latest documentation automatically

### Phase 2: Deploy CloudFormation Stack (10 minutes)

1. **Create Stack with Parameters**
   ```bash
   aws cloudformation create-stack \
     --stack-name wordpress-blog-prod \
     --template-body file://lightsail-wordpress.yaml \
     --parameters \
       ParameterKey=InstanceName,ParameterValue=wordpress-blog-prod-us-east-1 \
       ParameterKey=InstancePlan,ParameterValue=small_2_0 \
       ParameterKey=AvailabilityZone,ParameterValue=us-east-1a \
       ParameterKey=AdminEmail,ParameterValue=jono2411@outlook.com \
       ParameterKey=DomainName,ParameterValue=yourdomain.com \
       ParameterKey=EnableAutomaticSnapshots,ParameterValue=true \
     --region us-east-1
   ```

2. **Monitor Stack Creation**
   ```bash
   aws cloudformation describe-stacks \
     --stack-name wordpress-blog-prod \
     --region us-east-1 \
     --query "Stacks[0].StackStatus"
   ```

3. **Wait for Completion**
   ```bash
   aws cloudformation wait stack-create-complete \
     --stack-name wordpress-blog-prod \
     --region us-east-1
   ```

### Phase 3: Retrieve Deployment Information (2 minutes)

1. **Get Stack Outputs**
   ```bash
   aws cloudformation describe-stacks \
     --stack-name wordpress-blog-prod \
     --region us-east-1 \
     --query "Stacks[0].Outputs"
   ```

2. **Save Important Values**
   - Static IP Address
   - WordPress URL
   - WordPress Admin URL
   - SSH Command

### Phase 4: WordPress Initial Configuration (10 minutes)

1. **Retrieve Admin Password**
   ```bash
   # Use SSH command from stack outputs
   ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@YOUR_STATIC_IP
   cat bitnami_application_password
   ```

2. **Access WordPress Admin**
   - Navigate to WordPress Admin URL from outputs
   - Login with username: `user` and retrieved password
   - Change password immediately

3. **Configure WordPress Settings**
   - Settings > General: Set site title, tagline, timezone (Europe/London)
   - Settings > Permalinks: Choose "Post name" for SEO
   - Settings > Reading: Configure homepage display

### Phase 5: SSL/HTTPS Configuration (15 minutes)

**If using custom domain:**

1. **Update Domain Nameservers**
   - At your registrar, update nameservers to Lightsail's
   - Wait for DNS propagation (check with `nslookup yourdomain.com`)

2. **Verify DNS Records**
   ```bash
   aws lightsail get-domain \
     --domain-name yourdomain.com \
     --region us-east-1
   ```

3. **Enable HTTPS via Bitnami Tool**
   ```bash
   ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@YOUR_STATIC_IP
   sudo /opt/bitnami/bncert-tool
   ```
   - Follow prompts to configure Let's Encrypt SSL
   - Enter domain names (apex and www)
   - Provide admin email
   - Enable automatic renewal

4. **Update WordPress URLs**
   ```bash
   cd /opt/bitnami/wordpress
   sudo nano wp-config.php
   ```
   Add before "That's all, stop editing!":
   ```php
   define('WP_HOME','https://yourdomain.com');
   define('WP_SITEURL','https://yourdomain.com');
   ```

### Phase 6: Automated Backup Configuration (5 minutes)

1. **Enable Automatic Snapshots via CLI**
   ```bash
   aws lightsail enable-add-on \
     --resource-name wordpress-blog-prod-us-east-1 \
     --add-on-request addOnType=AutoSnapshot,autoSnapshotAddOnRequest={snapshotTimeOfDay=03:00} \
     --region us-east-1
   ```

2. **Verify Snapshot Configuration**
   ```bash
   aws lightsail get-auto-snapshots \
     --resource-name wordpress-blog-prod-us-east-1 \
     --region us-east-1
   ```

3. **Create Manual Snapshot (Baseline)**
   ```bash
   aws lightsail create-instance-snapshot \
     --instance-name wordpress-blog-prod-us-east-1 \
     --instance-snapshot-name wordpress-baseline-$(date +%Y%m%d) \
     --region us-east-1
   ```

### Phase 7: Security Hardening (15 minutes)

1. **Install Security Plugins via WP-CLI**
   ```bash
   ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@YOUR_STATIC_IP
   cd /opt/bitnami/wordpress
   
   # Install Wordfence
   sudo -u bitnami wp plugin install wordfence --activate
   
   # Install Limit Login Attempts
   sudo -u bitnami wp plugin install limit-login-attempts-reloaded --activate
   
   # Install UpdraftPlus for backups
   sudo -u bitnami wp plugin install updraftplus --activate
   ```

2. **Update All Components**
   ```bash
   sudo -u bitnami wp core update
   sudo -u bitnami wp plugin update --all
   sudo -u bitnami wp theme update --all
   ```

3. **Create New Admin User and Remove Default**
   ```bash
   sudo -u bitnami wp user create newadmin admin@yourdomain.com \
     --role=administrator \
     --user_pass=STRONG_PASSWORD_HERE
   
   sudo -u bitnami wp user delete user --reassign=newadmin
   ```

4. **Restrict SSH Access in CloudFormation**
   - Update template to restrict SSH to your IP
   - Update stack with new template

### Phase 8: Performance Optimization (10 minutes)

1. **Install Caching Plugin**
   ```bash
   ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@YOUR_STATIC_IP
   cd /opt/bitnami/wordpress
   sudo -u bitnami wp plugin install wp-super-cache --activate
   sudo -u bitnami wp super-cache enable
   ```

2. **Install Image Optimization**
   ```bash
   sudo -u bitnami wp plugin install smush --activate
   ```

3. **Configure Redis Cache (Optional)**
   ```bash
   sudo apt-get install redis-server -y
   sudo systemctl enable redis-server
   sudo -u bitnami wp plugin install redis-cache --activate
   sudo -u bitnami wp redis enable
   ```

### Phase 9: Monitoring Setup (5 minutes)

1. **Enable CloudWatch Metrics**
   ```bash
   aws lightsail put-instance-metric-data \
     --instance-name wordpress-blog-prod-us-east-1 \
     --region us-east-1
   ```

2. **Create CloudWatch Alarms**
   ```bash
   aws lightsail put-alarm \
     --alarm-name wordpress-high-cpu \
     --monitored-resource-name wordpress-blog-prod-us-east-1 \
     --metric-name CPUUtilization \
     --comparison-operator GreaterThanThreshold \
     --threshold 80 \
     --evaluation-periods 2 \
     --region us-east-1
   ```

3. **Use MCP to Query Metrics**
   - Ask Kiro: "Show me Lightsail monitoring best practices"
   - MCP will provide AWS documentation automatically

## Stack Management Operations

### Update Stack

```bash
aws cloudformation update-stack \
  --stack-name wordpress-blog-prod \
  --template-body file://lightsail-wordpress.yaml \
  --parameters \
    ParameterKey=InstancePlan,ParameterValue=medium_2_0 \
  --region us-east-1
```

### Delete Stack (Cleanup)

```bash
# Create final backup before deletion
aws lightsail create-instance-snapshot \
  --instance-name wordpress-blog-prod-us-east-1 \
  --instance-snapshot-name wordpress-final-backup-$(date +%Y%m%d) \
  --region us-east-1

# Delete stack
aws cloudformation delete-stack \
  --stack-name wordpress-blog-prod \
  --region us-east-1
```

### Export Stack Template

```bash
aws cloudformation get-template \
  --stack-name wordpress-blog-prod \
  --region us-east-1 \
  --query TemplateBody \
  --output text > exported-template.yaml
```

## MCP-Powered Operations

### Get AWS Documentation

Ask Kiro:
- "Search AWS Lightsail SSL certificate documentation"
- "Read AWS Lightsail backup documentation"
- "Show me Lightsail instance sizing recommendations"

### Get AWS Expert Guidance

Ask Kiro:
- "What are best practices for WordPress on Lightsail?"
- "How do I optimize Lightsail costs?"
- "What security measures should I implement?"

### Automated Troubleshooting

Ask Kiro:
- "My WordPress site is slow, what should I check?"
- "How do I restore from a Lightsail snapshot?"
- "SSL certificate is not working, help me debug"

## Maintenance Automation Scripts

### Daily Health Check Script

```bash
#!/bin/bash
# daily-health-check.sh

INSTANCE_NAME="wordpress-blog-prod-us-east-1"
REGION="us-east-1"

# Check instance state
STATE=$(aws lightsail get-instance-state \
  --instance-name $INSTANCE_NAME \
  --region $REGION \
  --query "state.name" \
  --output text)

echo "Instance State: $STATE"

# Check metrics
aws lightsail get-instance-metric-data \
  --instance-name $INSTANCE_NAME \
  --metric-name CPUUtilization \
  --period 3600 \
  --start-time $(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --unit Percent \
  --statistics Average \
  --region $REGION
```

### Weekly Backup Verification

```bash
#!/bin/bash
# verify-backups.sh

INSTANCE_NAME="wordpress-blog-prod-us-east-1"
REGION="us-east-1"

# List recent snapshots
aws lightsail get-instance-snapshots \
  --region $REGION \
  --query "instanceSnapshots[?fromInstanceName=='$INSTANCE_NAME'] | [0:7]"
```

## Cost Optimization

### Monitor Costs

```bash
# Get current month costs
aws ce get-cost-and-usage \
  --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --filter file://lightsail-filter.json
```

### Rightsizing Recommendations

Ask Kiro via MCP:
- "Analyze my Lightsail instance metrics and recommend optimal sizing"
- "What are cost optimization strategies for Lightsail?"

## Troubleshooting Guide

### Stack Creation Fails

1. **Check CloudFormation Events**
   ```bash
   aws cloudformation describe-stack-events \
     --stack-name wordpress-blog-prod \
     --region us-east-1
   ```

2. **Use MCP for Documentation**
   - Ask Kiro: "Why would Lightsail CloudFormation stack fail?"

### WordPress Not Accessible

1. **Verify Instance State**
   ```bash
   aws lightsail get-instance \
     --instance-name wordpress-blog-prod-us-east-1 \
     --region us-east-1
   ```

2. **Check Firewall Rules**
   ```bash
   aws lightsail get-instance-port-states \
     --instance-name wordpress-blog-prod-us-east-1 \
     --region us-east-1
   ```

### SSL Certificate Issues

1. **Verify DNS Propagation**
   ```bash
   nslookup yourdomain.com
   dig yourdomain.com
   ```

2. **Check Certificate Status**
   ```bash
   aws lightsail get-certificates \
     --region us-east-1
   ```

3. **Use MCP for Guidance**
   - Ask Kiro: "How do I troubleshoot Let's Encrypt SSL on Lightsail?"

## Post-Deployment Checklist

- [ ] CloudFormation stack created successfully
- [ ] Static IP attached and accessible
- [ ] WordPress accessible via static IP
- [ ] Admin password retrieved and changed
- [ ] New admin user created, default user removed
- [ ] Domain nameservers updated (if applicable)
- [ ] DNS records propagated and verified
- [ ] SSL certificate installed and working
- [ ] HTTPS redirect configured
- [ ] Automatic snapshots enabled and verified
- [ ] Security plugins installed and configured
- [ ] Caching plugin installed and configured
- [ ] Performance optimization completed
- [ ] CloudWatch alarms configured
- [ ] Backup verification script tested
- [ ] Health check script scheduled
- [ ] Test site on mobile and desktop
- [ ] Create test blog post
- [ ] Verify email functionality

## Cost Estimation (Monthly)

- Instance: $10 (small_2_0 plan)
- Static IP: Free (while attached)
- Data transfer: Included in plan
- Snapshots: ~$3 (7 daily snapshots × 60GB × $0.05/GB-month)
- Domain (if via Route 53): ~$1
- **Total: ~$14/month**

## Additional Resources

- CloudFormation Template in this repository
- MCP AWS Documentation Server for latest docs
- MCP AWS Core for expert guidance
- AWS Lightsail Console: https://lightsail.aws.amazon.com/

## Support

- Use MCP servers in Kiro for instant AWS documentation
- AWS Support through AWS Console
- CloudFormation documentation via MCP
- WordPress community support

---

**Deployment Time**: 30-45 minutes (automated)
**Skill Level**: Intermediate (CloudFormation knowledge helpful)
**Maintenance**: Mostly automated via scripts and snapshots
