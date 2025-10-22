#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-eu-west-2"
REGION="eu-west-2"
SNAPSHOT_PREFIX="wordpress-manual"

# Generate timestamp
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SNAPSHOT_NAME="${SNAPSHOT_PREFIX}-${TIMESTAMP}"

echo "Creating manual snapshot for instance: $INSTANCE_NAME"
echo "Snapshot name: $SNAPSHOT_NAME"
echo ""

# Create manual snapshot
aws lightsail create-instance-snapshot \
  --instance-name "$INSTANCE_NAME" \
  --instance-snapshot-name "$SNAPSHOT_NAME" \
  --region "$REGION"

echo ""
echo "✓ Manual snapshot creation initiated!"
echo ""
echo "Snapshot name: $SNAPSHOT_NAME"
echo ""
echo "Monitor snapshot creation with:"
echo "aws lightsail get-instance-snapshot --instance-snapshot-name $SNAPSHOT_NAME --region $REGION"
