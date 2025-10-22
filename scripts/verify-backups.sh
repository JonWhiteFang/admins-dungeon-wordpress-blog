#!/bin/bash
set -e

# Verify recent snapshots for Lightsail instance
# Usage: ./verify-backups.sh <instance-name>

INSTANCE_NAME="${1}"
REGION="eu-west-2"

if [ -z "$INSTANCE_NAME" ]; then
  echo "Usage: $0 <instance-name>"
  echo ""
  echo "Example:"
  echo "  $0 my-wordpress-blog"
  exit 1
fi

echo "=========================================="
echo "Backup Verification"
echo "Instance: $INSTANCE_NAME"
echo "Date: $(date)"
echo "=========================================="
echo ""

# Get automatic snapshots
echo "Automatic Snapshots:"
aws lightsail get-auto-snapshots \
  --resource-name "$INSTANCE_NAME" \
  --region "$REGION" \
  --query "autoSnapshots[*].{Date:date,Status:status}" \
  --output table

echo ""

# Get recent manual snapshots
echo "Recent Manual Snapshots (Last 7):"
aws lightsail get-instance-snapshots \
  --region "$REGION" \
  --query "instanceSnapshots[?fromInstanceName=='$INSTANCE_NAME'] | [0:7].{Name:name,CreatedAt:createdAt,State:state,Size:sizeInGb}" \
  --output table

echo ""
echo "=========================================="
echo "Backup verification complete"
echo "=========================================="
