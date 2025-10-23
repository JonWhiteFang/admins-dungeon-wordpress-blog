#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-us-east-1"
REGION="us-east-1"
DOMAIN_NAME="admin-dungeon.co.uk"  # Update with your domain
ADMIN_EMAIL="jono2411@outlook.com"  # Update with your email

echo "Configuring SSL certificate for: $DOMAIN_NAME"
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
echo "IMPORTANT: Before running this script, ensure:"
echo "1. Your domain DNS is pointing to $STATIC_IP"
echo "2. DNS propagation is complete (check with: dig $DOMAIN_NAME)"
echo ""
read -p "Press Enter to continue or Ctrl+C to cancel..."

echo ""
echo "Connecting to instance to configure SSL..."
echo ""

# SSH to instance and run bncert-tool
ssh -i ~/.ssh/LightsailDefaultKey-us-east-1.pem bitnami@"$STATIC_IP" << EOF
sudo /opt/bitnami/bncert-tool
EOF

echo ""
echo "SSL configuration complete!"
echo ""
echo "Your WordPress site should now be accessible at:"
echo "https://$DOMAIN_NAME"
echo "https://www.$DOMAIN_NAME"
