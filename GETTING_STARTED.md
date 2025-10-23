# Getting Started with AWS Lightsail WordPress Deployment

This guide will walk you through deploying your first WordPress blog using this Infrastructure as Code solution.

## Prerequisites Checklist

Before you begin, ensure you have:

- [ ] AWS account with billing enabled
- [ ] AWS CLI installed and configured
- [ ] Git installed (for cloning the repository)
- [ ] Domain name (optional, but recommended for production)
- [ ] Email address for SSL certificate notifications
- [ ] SSH key pair for Lightsail (will be created if needed)

## Step 1: Set Up AWS CLI

### Install AWS CLI

**Windows:**
```powershell
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

**macOS:**
```bash
brew install awscli
```

**Linux:**
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### Configure AWS CLI

```bash
aws configure
```

Enter your:
- AWS Access Key ID
- AWS Secret Access Key
- Default region: `us-east-1`
- Default output format: `json`

### Verify Configuration

```bash
aws sts get-caller-identity
aws lightsail get-regions --query "regions[?name=='us-east-1']"
```

## Step 2: Clone the Repository

```bash
git clone <your-repository-url>
cd lightsail-wordpress-deployment
```

## Step 3: Review Configuration

### Choose Your Instance Size

| Use Case | Recommended Plan | Cost/Month |
|----------|------------------|------------|
| Personal blog, low traffic | micro_2_0 | $5 |
| Small business blog | small_2_0 | $10 |
| Medium traffic site | medium_2_0 | $20 |
| High traffic site | large_2_0 | $40 |

### Prepare Your Parameters

Create a text file with your deployment parameters:

```
INSTANCE_NAME=my-wordpress-blog
ADMIN_EMAIL=your-email@example.com
DOMAIN_NAME=yourdomain.com  # Optional
INSTANCE_PLAN=small_2_0
```

## Step 4: Deploy Your WordPress Site

### Option A: Using the Deployment Script (Recommended)

```bash
cd scripts
chmod +x deploy-stack.sh
./deploy-stack.sh my-wordpress-blog your-email@example.com yourdomain.com small_2_0
```

### Option B: Using AWS CLI Directly

```bash
aws cloudformation create-stack \
  --stack-name wordpress-blog-prod \
  --template-body file://lightsail-wordpress.yaml \
  --parameters \
    ParameterKey=InstanceName,ParameterValue=my-wordpress-blog \
    ParameterKey=AdminEmail,ParameterValue=your-email@example.com \
    ParameterKey=DomainName,ParameterValue=yourdomain.com \
    ParameterKey=InstancePlan,ParameterValue=small_2_0 \
  --region us-east-1
```

### Monitor Deployment

```bash
# Check stack status
aws cloudformation describe-stacks \
  --stack-name wordpress-blog-prod \
  --region us-east-1 \
  --query "Stacks[0].StackStatus"

# Wait for completion (5-10 minutes)
aws cloudformation wait stack-create-complete \
  --stack-name wordpress-blog-prod \
  --region us-east-1
```

## Step 5: Get Your Site Information

```bash
cd scripts
chmod +x get-outputs.sh
./get-outputs.sh
```

Save the following from the outputs:
- Static IP Address
- WordPress URL
- WordPress Admin URL
- SSH Command

## Step 6: Access WordPress

### Retrieve Admin Password

```bash
# Use the SSH command from outputs
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@YOUR_STATIC_IP

# Get the password
cat bitnami_application_password

# Exit SSH
exit
```

### Log In to WordPress

1. Open the WordPress Admin URL in your browser
2. Username: `user`
3. Password: (from previous step)
4. **Important:** Change your password immediately!

## Step 7: Configure Your Domain (Optional)

If you provided a domain name during deployment:

### Update Nameservers

1. Log in to your domain registrar
2. Update nameservers to Lightsail's nameservers (from stack outputs):
   - ns-1.awsdns.com
   - ns-2.awsdns.co.uk
   - ns-3.awsdns.org
   - ns-4.awsdns.net

### Wait for DNS Propagation

```bash
# Check DNS propagation (may take 1-48 hours)
nslookup yourdomain.com
```

### Configure SSL Certificate

Once DNS has propagated:

```bash
# SSH to your instance
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@YOUR_STATIC_IP

# Run SSL configuration
sudo /opt/bitnami/bncert-tool
```

Follow the prompts:
1. Enter your domain: `yourdomain.com`
2. Enter www subdomain: `www.yourdomain.com`
3. Enter your email
4. Enable HTTP to HTTPS redirect: Yes
5. Enable automatic renewal: Yes

### Update WordPress URLs

```bash
# Edit wp-config.php
sudo nano /opt/bitnami/wordpress/wp-config.php
```

Add before "That's all, stop editing!":
```php
define('WP_HOME','https://yourdomain.com');
define('WP_SITEURL','https://yourdomain.com');
```

Save and exit (Ctrl+X, Y, Enter)

```bash
# Restart Apache
sudo /opt/bitnami/ctlscript.sh restart apache
exit
```

## Step 8: Secure Your Site

### Install Security Plugins

```bash
# SSH to your instance
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@YOUR_STATIC_IP

# Run security plugin installation script
cd /opt/bitnami/wordpress
sudo -u bitnami wp plugin install wordfence --activate
sudo -u bitnami wp plugin install limit-login-attempts-reloaded --activate
sudo -u bitnami wp plugin install updraftplus --activate

exit
```

### Create New Admin User

1. Log in to WordPress admin
2. Go to Users > Add New
3. Create a new admin user with a strong password
4. Log out and log in with the new user
5. Delete the default "user" account

## Step 9: Optimize Performance

### Install Caching Plugins

```bash
# SSH to your instance
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@YOUR_STATIC_IP

# Install caching plugins
cd /opt/bitnami/wordpress
sudo -u bitnami wp plugin install wp-super-cache --activate
sudo -u bitnami wp super-cache enable
sudo -u bitnami wp plugin install smush --activate

exit
```

### Configure WordPress Settings

1. Settings > General:
   - Set site title and tagline
   - Set timezone to Europe/London

2. Settings > Permalinks:
   - Choose "Post name" for SEO-friendly URLs

3. Settings > Reading:
   - Configure homepage display

## Step 10: Verify Backups

```bash
cd scripts
chmod +x verify-backups.sh
./verify-backups.sh my-wordpress-blog
```

You should see automatic snapshots being created daily.

## Next Steps

### Regular Maintenance

- **Daily:** Automatic snapshots run at 03:00 UTC
- **Weekly:** Check for WordPress/plugin updates
- **Monthly:** Review CloudWatch metrics and costs

### Monitoring

Set up CloudWatch alarms:
```bash
aws lightsail put-alarm \
  --alarm-name wordpress-high-cpu \
  --monitored-resource-name my-wordpress-blog \
  --metric-name CPUUtilization \
  --comparison-operator GreaterThanThreshold \
  --threshold 80 \
  --evaluation-periods 2 \
  --region us-east-1
```

### Create Your First Post

1. Log in to WordPress admin
2. Go to Posts > Add New
3. Create your first blog post
4. Publish and view on your site

## Troubleshooting

### Can't SSH to Instance

**Problem:** SSH connection refused or times out

**Solution:**
1. Verify instance is running:
   ```bash
   aws lightsail get-instance-state --instance-name my-wordpress-blog --region us-east-1
   ```
2. Check SSH key path is correct
3. Use Lightsail console browser-based SSH as alternative

### WordPress Not Accessible

**Problem:** Can't access WordPress URL

**Solution:**
1. Wait 5-10 minutes for initialization to complete
2. Check instance state (should be "running")
3. Verify firewall rules allow port 80 and 443
4. Check CloudFormation stack status

### SSL Certificate Not Working

**Problem:** HTTPS shows certificate error

**Solution:**
1. Verify DNS has propagated: `nslookup yourdomain.com`
2. Wait up to 48 hours for DNS propagation
3. Ensure nameservers are correctly set at registrar
4. Re-run bncert-tool if needed

### Stack Creation Failed

**Problem:** CloudFormation stack shows CREATE_FAILED

**Solution:**
1. Check stack events:
   ```bash
   aws cloudformation describe-stack-events --stack-name wordpress-blog-prod --region us-east-1
   ```
2. Fix the issue (usually parameter validation)
3. Delete failed stack:
   ```bash
   aws cloudformation delete-stack --stack-name wordpress-blog-prod --region us-east-1
   ```
4. Retry deployment with corrected parameters

## Getting Help

- **Documentation:** See README.md and other docs in this repository
- **Issues:** Open an issue on GitHub
- **AWS Support:** Use AWS Support Center for service issues
- **WordPress Support:** Visit wordpress.org/support

## Cost Monitoring

Keep track of your costs:

```bash
# View current month costs
aws ce get-cost-and-usage \
  --time-period Start=$(date +%Y-%m-01),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost
```

Expected monthly cost: ~$13-14 for small_2_0 instance with backups.

## Cleanup (If Needed)

To delete everything and stop costs:

```bash
# Create final backup
aws lightsail create-instance-snapshot \
  --instance-name my-wordpress-blog \
  --instance-snapshot-name wordpress-final-backup \
  --region us-east-1

# Delete stack
aws cloudformation delete-stack \
  --stack-name wordpress-blog-prod \
  --region us-east-1
```

## Success Checklist

- [ ] CloudFormation stack created successfully
- [ ] WordPress accessible via static IP
- [ ] Admin password retrieved and changed
- [ ] New admin user created, default user removed
- [ ] Domain configured (if applicable)
- [ ] SSL certificate working (if applicable)
- [ ] Security plugins installed
- [ ] Caching plugins installed
- [ ] Automatic backups verified
- [ ] First blog post created

Congratulations! Your WordPress blog is now live and production-ready! 🎉
