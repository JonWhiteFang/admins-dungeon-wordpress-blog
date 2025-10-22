#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-eu-west-2"
REGION="eu-west-2"
NEW_ADMIN_USERNAME="admin"  # Update with desired username
NEW_ADMIN_EMAIL="your-email@example.com"  # Update with your email

echo "Creating new WordPress admin user and removing default user"
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
echo "New admin username: $NEW_ADMIN_USERNAME"
echo "New admin email: $NEW_ADMIN_EMAIL"
echo ""

# SSH to instance and create new admin user
ssh -i ~/.ssh/LightsailDefaultKey-eu-west-2.pem bitnami@"$STATIC_IP" << EOF
cd /opt/bitnami/wordpress

echo "Creating new admin user: $NEW_ADMIN_USERNAME"
NEW_PASSWORD=\$(sudo -u bitnami wp user create "$NEW_ADMIN_USERNAME" "$NEW_ADMIN_EMAIL" \
  --role=administrator \
  --porcelain \
  --user_pass=\$(openssl rand -base64 16))

echo ""
echo "New admin user created!"
echo "Username: $NEW_ADMIN_USERNAME"
echo "Password: \$NEW_PASSWORD"
echo ""
echo "IMPORTANT: Save this password securely!"
echo ""

read -p "Press Enter after saving the password to continue with removing default user..."

echo ""
echo "Removing default 'user' account..."
sudo -u bitnami wp user delete user --reassign=\$(sudo -u bitnami wp user get "$NEW_ADMIN_USERNAME" --field=ID) --yes

echo ""
echo "✓ Default user removed successfully!"
EOF

echo ""
echo "✓ Admin user setup complete!"
echo ""
echo "You can now log in with your new admin credentials at:"
echo "http://$STATIC_IP/wp-admin"
