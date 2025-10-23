# Complete WordPress Deployment Guide
## From Repository to Production-Ready Site

This guide walks you through the complete deployment process, from downloading the repository to having a fully configured, production-ready WordPress site.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Initial Setup](#initial-setup)
3. [Configuration](#configuration)
4. [Deployment](#deployment)
5. [Post-Deployment Configuration](#post-deployment-configuration)
6. [Security Hardening](#security-hardening)
7. [Performance Optimization](#performance-optimization)
8. [Backup & Monitoring](#backup--monitoring)
9. [Domain & SSL Setup](#domain--ssl-setup)
10. [Verification & Testing](#verification--testing)
11. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Tools

1. **AWS CLI** (version 2.x or later)
   - macOS: `brew install awscli`
   - Linux: `curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && sudo ./aws/install`
   - Windows: Download from [AWS CLI installer](https://awscli.amazonaws.com/AWSCLIV2.msi)

2. **Git**
   - macOS: `brew install git`
   - Linux: `sudo apt-get install git` or `sudo yum install git`
   - Windows: Download from [git-scm.com](https://git-scm.com)

3. **SSH Client** (usually pre-installed on macOS/Linux)

4. **jq** (for JSON parsing, optional but recommended)
   - macOS: `brew install jq`
   - Linux: `sudo apt-get install jq` or `sudo yum install jq`

### AWS Requirements

- Active AWS account with billing enabled
- IAM user with permissions for:
  - CloudFormation (full access)
  - Lightsail (full access)
- AWS Access Key ID and Secret Access Key

### Additional Requirements

- Email address (for SSL certificate notifications)
- Domain name (optional, but recommended for production)
- SSH key pair in us-east-1 region (will be created if needed)

---

## Initial Setup

### Step 1: Download the Repository

```bash
# Clone the repository
git clone <your-repository-url>
cd lightsail-wordpress-deployment

# Verify directory structure
ls -la
```

You should see:
```
templates/          # CloudFormation template
scripts/            # Automation scripts
docs/              # Documentation
README.md
GETTING_STARTED.md
```

### Step 2: Configure AWS CLI

```bash
# Configure AWS credentials
aws configure
```

Enter the following when prompted:
- **AWS Access Key ID**: Your IAM user access key
- **AWS Secret Access Key**: Your IAM user secret key
- **Default region name**: `us-east-1`
- **Default output format**: `json`

### Step 3: Verify AWS Configuration

```bash
# Verify credentials
aws sts get-caller-identity

# Verify Lightsail access
aws lightsail get-regions --region us-east-1 --query "regions[?name=='us-east-1']"
```

Expected output should show your AWS account details and us-east-1 region information.

### Step 4: Create SSH Key Pair (if needed)

```bash
# Check if key already exists
aws lightsail get-key-pair --key-pair-name LightsailDefaultKey-us-east-1 --region us-east-1

# If key doesn't exist, create it
aws lightsail create-key-pair \
  --key-pair-name LightsailDefaultKey-us-east-1 \
  --region us-east-1 \
  --query 'privateKeyBase64' \
  --output text > ~/.ssh/LightsailDefaultKey-us-east-1.pem

# Set correct permissions
chmod 400 ~/.ssh/LightsailDefaultKey-us-east-1.pem
```

---

## Configuration

### Step 5: Choose Your Instance Plan

Select the appropriate plan based on your needs:

| Plan | vCPUs | RAM | Storage | Transfer | Price/Month | Use Case |
|------|-------|-----|---------|----------|-------------|----------|
| `micro_2_0` | 1 | 1 GB | 40 GB | 2 TB | $7 | Testing/Development |
| `small_2_0` | 1 | 2 GB | 60 GB | 3 TB | $14 | **Recommended for Production** |
| `medium_2_0` | 2 | 4 GB | 80 GB | 4 TB | $28 | High Traffic Sites |
| `large_2_0` | 2 | 8 GB | 160 GB | 5 TB | $56 | Very High Traffic |

### Step 6: Edit Deployment Script

Open the deployment script and update the configuration variables:

```bash
nano scripts/deployment/deploy-stack.sh
```

Update these variables:

```bash
# Required Configuration
INSTANCE_NAME="wordpress-blog-prod-us-east-1"  # Keep as-is or customize
INSTANCE_PLAN="small_2_0"                      # Choose from table above
ADMIN_EMAIL="your-email@example.com"           # YOUR EMAIL HERE

# Optional Configuration
DOMAIN_NAME=""                                  # Add your domain or leave empty
AVAILABILITY_ZONE="us-east-1a"                 # Usually keep default
ENABLE_SNAPSHOTS="true"                        # Keep enabled for backups
```

**Important Variables to Update:**
- `ADMIN_EMAIL`: Your actual email address (required for SSL certificates)
- `INSTANCE_PLAN`: Choose based on your traffic expectations
- `DOMAIN_NAME`: Your domain (e.g., "example.com") or leave empty for IP-only access

Save and exit (Ctrl+X, Y, Enter in nano).

---

## Deployment

### Step 7: Validate CloudFormation Template

Before deploying, validate the template syntax:

```bash
bash scripts/deployment/validate-template.sh
```

Expected output:
```
✓ Template is valid!
```

If validation fails, check the error message and fix any issues.

### Step 8: Deploy the Stack

```bash
bash scripts/deployment/deploy-stack.sh
```

This process takes **5-10 minutes**. You'll see:
```
Deploying WordPress stack: wordpress-blog-prod
Instance: wordpress-blog-prod-us-east-1
Plan: small_2_0
Region: us-east-1

Stack creation initiated. Monitoring status...
Current status: CREATE_IN_PROGRESS
...
✓ Stack created successfully!
✓ Deployment complete!
```

**What's happening during deployment:**
1. CloudFormation stack creation
2. Lightsail instance provisioning
3. WordPress (Bitnami) installation
4. Static IP allocation
5. Firewall configuration
6. System updates and PHP configuration
7. WordPress permissions setup

### Step 9: Get Stack Outputs

```bash
bash scripts/deployment/get-outputs.sh
```

**Save this information!** You'll need:
- Static IP Address
- WordPress URL
- WordPress Admin URL
- SSH Command
- DNS Nameservers (if using custom domain)

Example output:
```json
{
  "OutputKey": "StaticIPAddress",
  "OutputValue": "18.130.123.45"
},
{
  "OutputKey": "WordPressURL",
  "OutputValue": "http://18.130.123.45"
},
{
  "OutputKey": "SSHCommand",
  "OutputValue": "ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@18.130.123.45"
}
```

---

## Post-Deployment Configuration

### Step 10: Wait for WordPress Initialization

WordPress needs additional time to complete initialization:

```bash
# Wait 5 minutes after stack creation
sleep 300

# Or check initialization logs
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@52.206.160.25 \
  'tail -f /var/log/wordpress-init.log'
```

Look for: `"WordPress initialization completed"`

Press Ctrl+C to exit log viewing.

### Step 11: Retrieve Admin Password

```bash
bash scripts/configuration/get-admin-password.sh
```

**Save this password!** You'll need it to log in.

Example output:
```
Instance IP: 18.130.123.45
Connecting via SSH to retrieve password...
Abc123XyzSecurePassword

Default username: user
Admin URL: http://18.130.123.45/wp-admin
```

### Step 12: First WordPress Login

1. Open your browser and navigate to the Admin URL from Step 9
2. Log in with:
   - **Username**: `user`
   - **Password**: (from Step 11)
3. **Immediately change your password:**
   - Go to Users → Profile
   - Scroll to "New Password"
   - Generate a strong password
   - Click "Update Profile"

---

## Security Hardening

### Step 13: Install Security Plugins

```bash
bash scripts/security/install-security-plugins.sh
```

This installs:
- **Wordfence Security**: Firewall and malware scanner
- **Limit Login Attempts Reloaded**: Brute force protection
- **UpdraftPlus**: Backup plugin

**Time required**: 2-3 minutes

### Step 14: Configure Security Plugins

Log in to WordPress Admin and configure each plugin:

#### Wordfence Configuration:
1. Go to **Wordfence → Dashboard**
2. Click "Get Wordfence License" (free version is fine)
3. Enable "Extended Protection" (recommended)
4. Go to **Wordfence → Firewall**
5. Click "Optimize Firewall"
6. Run initial scan: **Wordfence → Scan → Start New Scan**

#### Limit Login Attempts:
1. Go to **Settings → Limit Login Attempts**
2. Recommended settings:
   - Allowed retries: 4
   - Minutes lockout: 20
   - Hours until retries reset: 12
   - Lockout after: 4 lockouts
3. Click "Save Settings"

#### UpdraftPlus:
1. Go to **Settings → UpdraftPlus Backups**
2. Click "Settings" tab
3. Configure backup schedule:
   - Files: Weekly
   - Database: Daily
4. Choose remote storage (recommended: Amazon S3, Google Drive, or Dropbox)
5. Click "Save Changes"

### Step 15: Create New Admin User

1. In WordPress Admin, go to **Users → Add New**
2. Fill in details:
   - **Username**: Choose a unique username (not "admin")
   - **Email**: Your email address
   - **Role**: Administrator
   - **Password**: Generate strong password
3. Click "Add New User"
4. Log out and log in with new credentials
5. Go to **Users → All Users**
6. Delete the default "user" account
7. Attribute posts to your new admin user

---

## Performance Optimization

### Step 16: Install Caching Plugins

```bash
bash scripts/performance/install-caching.sh
```

This installs and activates:
- **WP Super Cache**: Page caching
- **Smush**: Image optimization

**Time required**: 2-3 minutes

### Step 17: Configure Caching

#### WP Super Cache:
1. Go to **Settings → WP Super Cache**
2. Select "Caching On (Recommended)"
3. Click "Update Status"
4. Go to "Advanced" tab
5. Enable these options:
   - ✓ Cache hits to this website
   - ✓ Use mod_rewrite to serve cache files
   - ✓ Compress pages
   - ✓ Don't cache pages for known users
   - ✓ Cache rebuild
6. Click "Update Status"
7. Go to "Preload" tab
8. Click "Preload Cache Now"

#### Smush:
1. Go to **Smush → Dashboard**
2. Click "Bulk Smush Now" to optimize existing images
3. Enable "Automatic compression" for future uploads
4. Enable "Strip my image metadata"

### Step 18: Install Redis (Optional, for High Traffic)

```bash
bash scripts/performance/install-redis.sh
```

This installs Redis object caching for database query optimization.

**Note**: Only needed for sites with >10,000 monthly visitors.

### Step 19: Configure WordPress Settings

1. **Permalinks** (SEO-friendly URLs):
   - Go to **Settings → Permalinks**
   - Select "Post name"
   - Click "Save Changes"

2. **General Settings**:
   - Go to **Settings → General**
   - Set Site Title and Tagline
   - Set Timezone to "Europe/London"
   - Click "Save Changes"

3. **Reading Settings**:
   - Go to **Settings → Reading**
   - Configure homepage display
   - Set "Blog pages show at most" to 10
   - Click "Save Changes"

---

## Backup & Monitoring

### Step 20: Enable Automatic Snapshots

```bash
bash scripts/backup/enable-snapshots.sh
```

This configures:
- Daily snapshots at 03:00 UTC
- 7-day retention period
- Automatic cleanup of old snapshots

### Step 21: Verify Backup Configuration

```bash
bash scripts/backup/verify-snapshots.sh
```

Expected output:
```
✓ Automatic snapshots enabled
Snapshot time: 03:00 UTC
```

### Step 22: Create Manual Snapshot (Baseline)

```bash
bash scripts/backup/create-manual-snapshot.sh
```

This creates a baseline snapshot before making any content changes.

### Step 23: Configure CloudWatch Monitoring

```bash
bash scripts/monitoring/enable-monitoring.sh
```

This verifies CloudWatch metrics are being collected.

### Step 24: Create CloudWatch Alarms

```bash
bash scripts/monitoring/create-alarms.sh
```

This creates alarms for:
- High CPU utilization (>80%)
- High network traffic
- Instance state changes

You'll receive email notifications when alarms trigger.

---

## Domain & SSL Setup

**Skip this section if you're not using a custom domain.**

### Step 25: Update DNS Nameservers

1. Log in to your domain registrar (GoDaddy, Namecheap, etc.)
2. Find DNS/Nameserver settings
3. Replace existing nameservers with Lightsail nameservers (from Step 9):
   ```
   ns-1.awsdns.com
   ns-2.awsdns.co.uk
   ns-3.awsdns.org
   ns-4.awsdns.net
   ```
4. Save changes

**Note**: DNS propagation takes 1-48 hours (usually 2-4 hours).

### Step 26: Verify DNS Propagation

```bash
# Check if DNS has propagated
nslookup yourdomain.com

# Or use dig
dig yourdomain.com
```

Wait until the IP address matches your Static IP from Step 9.

### Step 27: Configure SSL Certificate

Once DNS has propagated:

```bash
# SSH to your instance
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@<YOUR_STATIC_IP>

# Run SSL configuration tool
sudo /opt/bitnami/bncert-tool
```

Follow the prompts:
1. **Domain list**: Enter `yourdomain.com www.yourdomain.com`
2. **Enable HTTP to HTTPS redirect**: `Y`
3. **Enable non-www to www redirect**: `Y` (or `N` if you prefer non-www)
4. **Enable www to non-www redirect**: `N` (or `Y` if you prefer non-www)
5. **Email address**: Enter your email
6. **Agree to Let's Encrypt terms**: `Y`

The tool will:
- Request SSL certificate from Let's Encrypt
- Configure Apache for HTTPS
- Set up automatic renewal
- Restart Apache

### Step 28: Update WordPress URLs

Still in SSH session:

```bash
# Edit wp-config.php
sudo nano /opt/bitnami/wordpress/wp-config.php
```

Add these lines **before** `/* That's all, stop editing! */`:

```php
define('WP_HOME','https://yourdomain.com');
define('WP_SITEURL','https://yourdomain.com');
```

Save and exit (Ctrl+X, Y, Enter).

```bash
# Restart Apache
sudo /opt/bitnami/ctlscript.sh restart apache

# Exit SSH
exit
```

### Step 29: Verify SSL

1. Open `https://yourdomain.com` in your browser
2. Check for padlock icon in address bar
3. Click padlock to verify certificate details
4. Test at [SSL Labs](https://www.ssllabs.com/ssltest/)

---

## Verification & Testing

### Step 30: Run Health Check

```bash
bash scripts/monitoring/daily-health-check.sh
```

This verifies:
- Instance is running
- CPU utilization is normal
- Network traffic is normal
- WordPress is accessible

### Step 31: Verify All Backups

```bash
bash scripts/backup/verify-backups.sh
```

You should see:
- Automatic snapshots enabled
- At least one snapshot created
- Snapshot retention configured

### Step 32: Test WordPress Functionality

1. **Create a test post**:
   - Go to **Posts → Add New**
   - Title: "Test Post"
   - Content: "This is a test post."
   - Click "Publish"
   - Click "View Post" to verify

2. **Test caching**:
   - Visit your site in incognito/private mode
   - Check page load speed
   - Verify WP Super Cache is working: **Settings → WP Super Cache → Test Cache**

3. **Test security**:
   - Try logging in with wrong password 5 times
   - Verify you get locked out (Limit Login Attempts working)
   - Wait 20 minutes or whitelist your IP

4. **Test image upload**:
   - Go to **Media → Add New**
   - Upload a test image
   - Verify Smush optimizes it automatically

### Step 33: Create Your First Real Post

1. Go to **Posts → Add New**
2. Create your first blog post
3. Add featured image
4. Set categories and tags
5. Click "Publish"
6. View on your live site

---

## Troubleshooting

### Issue: Can't SSH to Instance

**Symptoms**: Connection timeout or refused

**Solutions**:
```bash
# 1. Verify instance is running
aws lightsail get-instance-state \
  --instance-name wordpress-blog-prod-us-east-1 \
  --region us-east-1

# 2. Check SSH key permissions
chmod 400 ~/.ssh/LightsailDefaultKey-us-east-1.pem

# 3. Verify firewall allows SSH (port 22)
aws lightsail get-instance-port-states \
  --instance-name wordpress-blog-prod-us-east-1 \
  --region us-east-1

# 4. Use Lightsail browser-based SSH as alternative
# Go to AWS Console → Lightsail → Instance → Connect
```

### Issue: WordPress Not Accessible

**Symptoms**: Can't access WordPress URL

**Solutions**:
```bash
# 1. Wait for initialization (5-10 minutes after stack creation)
sleep 300

# 2. Check initialization logs
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@<IP> \
  'cat /var/log/wordpress-init.log'

# 3. Verify Apache is running
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@<IP> \
  'sudo /opt/bitnami/ctlscript.sh status apache'

# 4. Restart Apache if needed
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@<IP> \
  'sudo /opt/bitnami/ctlscript.sh restart apache'
```

### Issue: Stack Creation Failed

**Symptoms**: CloudFormation shows CREATE_FAILED

**Solutions**:
```bash
# 1. Check stack events for error details
aws cloudformation describe-stack-events \
  --stack-name wordpress-blog-prod \
  --region us-east-1 \
  --query "StackEvents[?ResourceStatus=='CREATE_FAILED']"

# 2. Common issues:
# - Invalid email format in ADMIN_EMAIL
# - Invalid domain name format
# - Invalid instance plan name
# - Insufficient IAM permissions

# 3. Delete failed stack
aws cloudformation delete-stack \
  --stack-name wordpress-blog-prod \
  --region us-east-1

# 4. Fix the issue in deploy-stack.sh and retry
bash scripts/deployment/deploy-stack.sh
```

### Issue: SSL Certificate Not Working

**Symptoms**: HTTPS shows certificate error

**Solutions**:
```bash
# 1. Verify DNS has propagated
nslookup yourdomain.com

# 2. Check if IP matches your Static IP
dig yourdomain.com +short

# 3. Wait longer (DNS can take up to 48 hours)

# 4. Re-run bncert-tool
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@<IP>
sudo /opt/bitnami/bncert-tool

# 5. Check Let's Encrypt logs
sudo cat /opt/bitnami/letsencrypt/letsencrypt.log
```

### Issue: High CPU Usage

**Symptoms**: Site is slow, CloudWatch shows high CPU

**Solutions**:
1. Check for problematic plugins:
   - Deactivate plugins one by one
   - Identify the culprit
   - Find alternative or optimize

2. Upgrade instance plan:
   ```bash
   # Edit scripts/deployment/update-stack.sh
   # Change INSTANCE_PLAN to medium_2_0 or large_2_0
   bash scripts/deployment/update-stack.sh
   ```

3. Enable Redis caching:
   ```bash
   bash scripts/performance/install-redis.sh
   ```

### Issue: Backup Failures

**Symptoms**: No snapshots being created

**Solutions**:
```bash
# 1. Verify automatic snapshots are enabled
bash scripts/backup/verify-snapshots.sh

# 2. Re-enable if needed
bash scripts/backup/enable-snapshots.sh

# 3. Create manual snapshot to test
bash scripts/backup/create-manual-snapshot.sh

# 4. Check Lightsail service status
aws lightsail get-instance \
  --instance-name wordpress-blog-prod-us-east-1 \
  --region us-east-1 \
  --query "instance.addOns"
```

### Issue: Can't Log In to WordPress

**Symptoms**: Locked out after too many attempts

**Solutions**:
```bash
# 1. Whitelist your IP in Limit Login Attempts
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@<IP>
cd /opt/bitnami/wordpress
sudo -u bitnami wp plugin deactivate limit-login-attempts-reloaded
exit

# 2. Log in to WordPress
# 3. Go to Settings → Limit Login Attempts → Lockouts
# 4. Clear your IP from lockouts
# 5. Re-activate plugin
```

---

## Maintenance Schedule

### Daily (Automated)
- Automatic snapshots at 03:00 UTC
- CloudWatch metrics collection

### Weekly (Manual)
```bash
# Check for WordPress updates
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@<IP>
cd /opt/bitnami/wordpress
sudo -u bitnami wp core check-update
sudo -u bitnami wp plugin list --update=available
sudo -u bitnami wp theme list --update=available
exit
```

### Monthly (Manual)
```bash
# Run health check
bash scripts/monitoring/daily-health-check.sh

# Verify backups
bash scripts/backup/verify-backups.sh

# Review CloudWatch metrics
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lightsail \
  --metric-name CPUUtilization \
  --dimensions Name=InstanceName,Value=wordpress-blog-prod-us-east-1 \
  --start-time $(date -u -d '30 days ago' +%Y-%m-%dT%H:%M:%S) \
  --end-time $(date -u +%Y-%m-%dT%H:%M:%S) \
  --period 86400 \
  --statistics Average \
  --region us-east-1

# Review costs
aws ce get-cost-and-usage \
  --time-period Start=$(date -d '1 month ago' +%Y-%m-01),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --filter file://<(echo '{"Dimensions":{"Key":"SERVICE","Values":["Amazon Lightsail"]}}')
```

---

## Cost Summary

### Monthly Costs (small_2_0 plan)
- Lightsail instance: **$14.00**
- Static IP: **$0.00** (included)
- DNS zone: **$0.50**
- Snapshots (7 days × ~$0.05/day): **~$0.35**
- Data transfer: **$0.00** (3 TB included)

**Total: ~$14.85/month**

### Cost Optimization Tips
1. Use micro_2_0 for low-traffic sites ($7/month)
2. Reduce snapshot retention if needed
3. Monitor data transfer usage
4. Delete unused snapshots manually

---

## Success Checklist

Use this checklist to verify your deployment:

- [ ] AWS CLI configured and tested
- [ ] Repository cloned and scripts reviewed
- [ ] SSH key pair created in us-east-1
- [ ] Deployment script configured with your details
- [ ] CloudFormation template validated
- [ ] Stack deployed successfully (5-10 minutes)
- [ ] Stack outputs retrieved and saved
- [ ] WordPress initialization completed (5 minutes)
- [ ] Admin password retrieved
- [ ] First login successful and password changed
- [ ] Security plugins installed and configured
- [ ] New admin user created, default user deleted
- [ ] Caching plugins installed and configured
- [ ] WordPress settings optimized
- [ ] Automatic snapshots enabled and verified
- [ ] CloudWatch monitoring configured
- [ ] Domain DNS updated (if applicable)
- [ ] SSL certificate configured (if applicable)
- [ ] Health check passed
- [ ] Test post created and published
- [ ] All functionality tested

---

## Next Steps

### Content Creation
1. Install a theme: **Appearance → Themes → Add New**
2. Customize theme: **Appearance → Customize**
3. Create pages: **Pages → Add New** (About, Contact, etc.)
4. Set up navigation: **Appearance → Menus**
5. Configure widgets: **Appearance → Widgets**

### SEO Optimization
1. Install Yoast SEO: `sudo -u bitnami wp plugin install wordpress-seo --activate`
2. Configure XML sitemaps
3. Submit sitemap to Google Search Console
4. Set up Google Analytics

### Additional Plugins (Optional)
- Contact Form 7 (contact forms)
- Akismet (spam protection)
- WP Rocket (advanced caching, paid)
- Jetpack (multiple features)

### Marketing
1. Set up email newsletter (Mailchimp, ConvertKit)
2. Connect social media accounts
3. Create content calendar
4. Plan SEO strategy

---

## Support Resources

- **AWS Lightsail Documentation**: https://docs.aws.amazon.com/lightsail/
- **WordPress Documentation**: https://wordpress.org/support/
- **Bitnami WordPress Stack**: https://docs.bitnami.com/aws/apps/wordpress/
- **CloudFormation Documentation**: https://docs.aws.amazon.com/cloudformation/
- **This Project's README**: See README.md in repository

---

## Cleanup (If Needed)

To completely remove the deployment and stop all costs:

```bash
# 1. Create final backup
bash scripts/backup/create-manual-snapshot.sh

# 2. Delete CloudFormation stack
bash scripts/deployment/delete-stack.sh

# 3. Verify deletion
aws cloudformation describe-stacks \
  --stack-name wordpress-blog-prod \
  --region us-east-1

# 4. Manually delete snapshots if needed (to stop snapshot costs)
aws lightsail get-instance-snapshots --region us-east-1
aws lightsail delete-instance-snapshot \
  --instance-snapshot-name <snapshot-name> \
  --region us-east-1
```

---

## Congratulations! 🎉

Your WordPress blog is now fully deployed and production-ready!

**Total deployment time**: 30-50 minutes
**Monthly cost**: ~$15
**Uptime**: 99.9%+ (AWS SLA)

You now have:
- ✓ Production-ready WordPress installation
- ✓ Security hardening (Wordfence, login limits)
- ✓ Performance optimization (caching, image optimization)
- ✓ Automated daily backups (7-day retention)
- ✓ CloudWatch monitoring and alarms
- ✓ SSL certificate (if using custom domain)
- ✓ Infrastructure as Code (reproducible deployment)

Start creating content and growing your blog!
