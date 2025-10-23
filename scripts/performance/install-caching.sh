#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-us-east-1"
REGION="us-east-1"

echo "Installing WordPress caching and optimization plugins"
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

# SSH to instance and install caching plugins
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@"$STATIC_IP" << 'EOF'
cd /opt/bitnami/wordpress

echo "Installing WP Super Cache..."
sudo /opt/bitnami/wp-cli/bin/wp plugin install wp-super-cache --activate --allow-root --path=/opt/bitnami/wordpress

echo "Enabling WP Super Cache..."
sudo /opt/bitnami/wp-cli/bin/wp super-cache enable --allow-root --path=/opt/bitnami/wordpress

echo ""
echo "Installing Smush Image Optimization..."
sudo /opt/bitnami/wp-cli/bin/wp plugin install wp-smushit --activate --allow-root --path=/opt/bitnami/wordpress

echo ""
echo "✓ Caching plugins installed successfully!"
echo ""
echo "Next steps:"
echo "1. Configure WP Super Cache: Go to Settings > WP Super Cache"
echo "2. Configure Smush: Go to Smush > Dashboard"
echo "3. Run bulk image optimization in Smush"
EOF

echo ""
echo "✓ Installation complete!"
