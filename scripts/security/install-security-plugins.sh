#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-us-east-1"
REGION="us-east-1"

echo "Installing WordPress security plugins"
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

# SSH to instance and install security plugins
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@"$STATIC_IP" << 'EOF'
cd /opt/bitnami/wordpress

echo "Installing Wordfence Security..."
sudo wp plugin install wordfence --activate --allow-root

echo "Installing Limit Login Attempts Reloaded..."
sudo wp plugin install limit-login-attempts-reloaded --activate --allow-root

echo "Installing UpdraftPlus Backup..."
sudo wp plugin install updraftplus --activate --allow-root

echo ""
echo "✓ Security plugins installed successfully!"
echo ""
echo "Next steps:"
echo "1. Configure Wordfence: Go to WordPress Admin > Wordfence > Dashboard"
echo "2. Configure Limit Login Attempts: Go to Settings > Limit Login Attempts"
echo "3. Configure UpdraftPlus: Go to Settings > UpdraftPlus Backups"
EOF

echo ""
echo "✓ Installation complete!"
