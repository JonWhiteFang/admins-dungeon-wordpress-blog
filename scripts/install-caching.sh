#!/bin/bash
set -e

# Install and configure WordPress caching plugins
# This script should be run ON the Lightsail instance via SSH
# Usage: ./install-caching.sh [--with-redis]

INSTALL_REDIS=false

if [ "$1" = "--with-redis" ]; then
  INSTALL_REDIS=true
fi

echo "Installing WordPress caching plugins..."
echo ""

cd /opt/bitnami/wordpress

# Install WP Super Cache
echo "Installing WP Super Cache..."
sudo -u bitnami wp plugin install wp-super-cache --activate
sudo -u bitnami wp super-cache enable

# Install Smush
echo "Installing Smush (Image Optimization)..."
sudo -u bitnami wp plugin install smush --activate

# Install Redis if requested
if [ "$INSTALL_REDIS" = true ]; then
  echo "Installing Redis server..."
  sudo apt-get update
  sudo apt-get install -y redis-server
  sudo systemctl enable redis-server
  sudo systemctl start redis-server
  
  echo "Installing Redis Cache plugin..."
  sudo -u bitnami wp plugin install redis-cache --activate
  sudo -u bitnami wp redis enable
  
  echo "Redis cache enabled!"
fi

echo ""
echo "Caching plugins installed successfully!"
echo ""
echo "Installed plugins:"
echo "  - WP Super Cache (Page Caching)"
echo "  - Smush (Image Optimization)"
if [ "$INSTALL_REDIS" = true ]; then
  echo "  - Redis Cache (Object Caching)"
fi
echo ""
echo "Next steps:"
echo "1. Test your site performance"
echo "2. Configure Smush settings in WordPress admin"
echo "3. Monitor cache hit rates"
