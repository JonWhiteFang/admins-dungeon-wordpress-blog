#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-us-east-1"
REGION="us-east-1"
DOMAIN_NAME="example.com"  # Update with your domain
USE_HTTPS="true"  # Set to "false" if not using SSL

echo "Updating WordPress configuration for: $DOMAIN_NAME"
echo ""

# Get instance IP
STATIC_IP=$(aws lightsail get-static-ip \
  --static-ip-name "${INSTANCE_NAME}-static-ip" \
  --region "$REGION" \
  --query "staticIp.ipAddress" \
  --output text)

if [[ -z "$STATIC_IP" ]]; then
  echo "Error: Could not retrieve static IP for instance"
  exit 1
fi

echo "Instance IP: $STATIC_IP"
echo ""

# Determine protocol
if [[ "$USE_HTTPS" == "true" ]]; then
  PROTOCOL="https"
else
  PROTOCOL="http"
fi

SITE_URL="${PROTOCOL}://${DOMAIN_NAME}"

echo "Setting WordPress URLs to: $SITE_URL"
echo ""

# SSH to instance and update wp-config.php
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@"$STATIC_IP" << EOF
# Backup wp-config.php
sudo cp /opt/bitnami/wordpress/wp-config.php /opt/bitnami/wordpress/wp-config.php.backup

# Add WP_HOME and WP_SITEURL constants
sudo sed -i "/define( 'DB_COLLATE', '' );/a\\
\\
/* Custom Site URL Configuration */\\
define( 'WP_HOME', '$SITE_URL' );\\
define( 'WP_SITEURL', '$SITE_URL' );" /opt/bitnami/wordpress/wp-config.php

echo "WordPress configuration updated successfully"
echo "Backup saved to: /opt/bitnami/wordpress/wp-config.php.backup"
EOF

echo ""
echo "✓ WordPress URLs updated to: $SITE_URL"
echo ""
echo "You may need to update URLs in the database using WP-CLI:"
echo "ssh bitnami@$STATIC_IP"
echo "sudo -u bitnami wp search-replace 'http://$STATIC_IP' '$SITE_URL' --all-tables"
