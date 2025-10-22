#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-eu-west-2"
REGION="eu-west-2"

echo "Installing and configuring Redis for WordPress object caching"
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

# SSH to instance and install Redis
ssh -i ~/.ssh/LightsailDefaultKey-eu-west-2.pem bitnami@"$STATIC_IP" << 'EOF'
echo "Installing Redis server..."
sudo apt-get update
sudo apt-get install -y redis-server

echo "Enabling Redis service..."
sudo systemctl enable redis-server
sudo systemctl start redis-server

echo "Verifying Redis installation..."
redis-cli ping

echo ""
echo "Installing Redis Object Cache plugin..."
cd /opt/bitnami/wordpress
sudo -u bitnami wp plugin install redis-cache --activate

echo "Enabling Redis object cache..."
sudo -u bitnami wp redis enable

echo ""
echo "✓ Redis installation and configuration complete!"
echo ""
echo "Redis status:"
sudo systemctl status redis-server --no-pager

echo ""
echo "Redis cache info:"
sudo -u bitnami wp redis info
EOF

echo ""
echo "✓ Redis setup complete!"
