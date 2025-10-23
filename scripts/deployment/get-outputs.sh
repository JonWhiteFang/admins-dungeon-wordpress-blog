#!/bin/bash
set -e

# Configuration
STACK_NAME="wordpress-blog-prod"
REGION="us-east-1"

echo "Retrieving outputs for stack: $STACK_NAME"
echo ""

# Get stack outputs
OUTPUTS=$(aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query "Stacks[0].Outputs" \
  --output json)

# Check if outputs exist
if [[ "$OUTPUTS" == "null" ]] || [[ "$OUTPUTS" == "[]" ]]; then
  echo "No outputs found for stack $STACK_NAME"
  exit 1
fi

# Parse and display outputs
echo "=== Stack Outputs ==="
echo ""

# Instance Name
INSTANCE_NAME=$(echo "$OUTPUTS" | jq -r '.[] | select(.OutputKey=="InstanceName") | .OutputValue')
echo "Instance Name: $INSTANCE_NAME"

# Static IP
STATIC_IP=$(echo "$OUTPUTS" | jq -r '.[] | select(.OutputKey=="StaticIPAddress") | .OutputValue')
echo "Static IP: $STATIC_IP"

# WordPress URL
WP_URL=$(echo "$OUTPUTS" | jq -r '.[] | select(.OutputKey=="WordPressURL") | .OutputValue')
echo "WordPress URL: $WP_URL"

# Admin URL
ADMIN_URL=$(echo "$OUTPUTS" | jq -r '.[] | select(.OutputKey=="WordPressAdminURL") | .OutputValue')
echo "Admin URL: $ADMIN_URL"

# SSH Command
SSH_CMD=$(echo "$OUTPUTS" | jq -r '.[] | select(.OutputKey=="SSHCommand") | .OutputValue')
echo "SSH Command: $SSH_CMD"

# Domain Nameservers (if configured)
NAMESERVERS=$(echo "$OUTPUTS" | jq -r '.[] | select(.OutputKey=="DomainNameServers") | .OutputValue' 2>/dev/null || echo "")
if [[ -n "$NAMESERVERS" ]]; then
  echo ""
  echo "Domain Nameservers:"
  echo "$NAMESERVERS"
fi

# Next Steps
NEXT_STEPS=$(echo "$OUTPUTS" | jq -r '.[] | select(.OutputKey=="NextSteps") | .OutputValue')
echo ""
echo "=== Next Steps ==="
echo "$NEXT_STEPS"
