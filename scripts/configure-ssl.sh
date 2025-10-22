#!/bin/bash
set -e

# Configure SSL certificate using Bitnami bncert-tool
# This script should be run ON the Lightsail instance via SSH
# Usage: ./configure-ssl.sh <domain> <email>

DOMAIN="${1}"
EMAIL="${2}"

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
  echo "Usage: $0 <domain> <email>"
  echo ""
  echo "Example:"
  echo "  $0 example.com admin@example.com"
  exit 1
fi

echo "Configuring SSL certificate for: $DOMAIN"
echo "Email: $EMAIL"
echo ""

# Run bncert-tool
sudo /opt/bitnami/bncert-tool <<EOF
$DOMAIN
www.$DOMAIN
$EMAIL
Y
Y
EOF

echo ""
echo "SSL certificate configured successfully!"
echo ""
echo "Next steps:"
echo "1. Update wp-config.php with HTTPS URLs"
echo "2. Test your site at https://$DOMAIN"
