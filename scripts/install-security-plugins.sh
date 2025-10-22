#!/bin/bash
set -e

# Install and activate WordPress security plugins
# This script should be run ON the Lightsail instance via SSH
# Usage: ./install-security-plugins.sh

echo "Installing WordPress security plugins..."
echo ""

cd /opt/bitnami/wordpress

# Install Wordfence
echo "Installing Wordfence..."
sudo -u bitnami wp plugin install wordfence --activate

# Install Limit Login Attempts Reloaded
echo "Installing Limit Login Attempts Reloaded..."
sudo -u bitnami wp plugin install limit-login-attempts-reloaded --activate

# Install UpdraftPlus
echo "Installing UpdraftPlus..."
sudo -u bitnami wp plugin install updraftplus --activate

# Update all plugins
echo "Updating all plugins..."
sudo -u bitnami wp plugin update --all

# Update WordPress core
echo "Updating WordPress core..."
sudo -u bitnami wp core update

# Update themes
echo "Updating themes..."
sudo -u bitnami wp theme update --all

echo ""
echo "Security plugins installed successfully!"
echo ""
echo "Installed plugins:"
echo "  - Wordfence (Web Application Firewall & Security Scanner)"
echo "  - Limit Login Attempts Reloaded (Brute Force Protection)"
echo "  - UpdraftPlus (Backup & Restore)"
echo ""
echo "Next steps:"
echo "1. Configure Wordfence in WordPress admin"
echo "2. Set up UpdraftPlus backup schedule"
echo "3. Create a new admin user and remove default 'user' account"
