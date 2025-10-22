#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-eu-west-2"
REGION="eu-west-2"

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
ssh -i ~/.ssh/LightsailDefaultKey-eu-west-2.pem bitnami@"$STATIC_IP" << 'EOF'
cd /opt/bitnami/wordpress

echo "Installing Wordfence Security..."
sudo -u bitnami wp plugin install wordfence --activate

echo "Installing Limit Login Attempts Reloaded..."
sudo -u bitnami wp plugin install limit-login-attempts-reloaded --activate

echo "Installing UpdraftPlus Backup..."
sudo -u bitnami wp plugin install updraftplus --activate

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
