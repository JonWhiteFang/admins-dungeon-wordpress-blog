#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-us-east-1"
REGION="us-east-1"
SNAPSHOT_TIME="03:00"  # UTC time for daily snapshots

echo "Enabling automatic snapshots for instance: $INSTANCE_NAME"
echo "Snapshot time: $SNAPSHOT_TIME UTC"
echo ""

# Enable automatic snapshots
aws lightsail enable-add-on \
  --resource-name "$INSTANCE_NAME" \
  --add-on-request addOnType=AutoSnapshot,autoSnapshotAddOnRequest={snapshotTimeOfDay="$SNAPSHOT_TIME"} \
  --region "$REGION"

echo ""
echo "✓ Automatic snapshots enabled successfully!"
echo ""
echo "Snapshot configuration:"
echo "- Daily snapshots at $SNAPSHOT_TIME UTC"
echo "- 7-day retention period"
echo ""
echo "Run './scripts/verify-snapshots.sh' to verify snapshot configuration."
