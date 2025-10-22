#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-eu-west-2"
REGION="eu-west-2"

echo "Verifying automatic snapshots for instance: $INSTANCE_NAME"
echo ""

# Get auto-snapshot configuration
echo "=== Auto-Snapshot Configuration ==="
aws lightsail get-auto-snapshots \
  --resource-name "$INSTANCE_NAME" \
  --region "$REGION" \
  --output table

echo ""
echo "=== Recent Snapshots (Last 7 Days) ==="
aws lightsail get-instance-snapshots \
  --region "$REGION" \
  --query "instanceSnapshots[?fromInstanceName=='$INSTANCE_NAME'] | sort_by(@, &createdAt) | reverse(@) | [0:7].{Name:name, CreatedAt:createdAt, State:state, Size:sizeInGb}" \
  --output table

echo ""
echo "✓ Snapshot verification complete!"
