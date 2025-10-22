#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-eu-west-2"
REGION="eu-west-2"

echo "Updating WordPress core, plugins, and themes"
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

# SSH to instance and update WordPress
ssh -i ~/.ssh/LightsailDefaultKey-eu-west-2.pem bitnami@"$STATIC_IP" << 'EOF'
cd /opt/bitnami/wordpress

echo "Checking for WordPress core updates..."
sudo -u bitnami wp core update

echo ""
echo "Updating all plugins..."
sudo -u bitnami wp plugin update --all

echo ""
echo "Updating all themes..."
sudo -u bitnami wp theme update --all

echo ""
echo "Current WordPress version:"
sudo -u bitnami wp core version

echo ""
echo "✓ All updates complete!"
EOF

echo ""
echo "✓ WordPress update complete!"
