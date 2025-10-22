#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-eu-west-2"
REGION="eu-west-2"

echo "Retrieving WordPress admin password for instance: $INSTANCE_NAME"
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

# SSH to instance and retrieve password
echo "Connecting via SSH to retrieve password..."
ssh -i ~/.ssh/LightsailDefaultKey-eu-west-2.pem bitnami@"$STATIC_IP" \
  'cat /home/bitnami/bitnami_application_password'

echo ""
echo ""
echo "Default username: user"
echo "Admin URL: http://$STATIC_IP/wp-admin"
