#!/bin/bash
set -e

# Enable automatic snapshots for Lightsail instance
# Usage: ./enable-snapshots.sh <instance-name> [snapshot-time]

INSTANCE_NAME="${1}"
SNAPSHOT_TIME="${2:-03:00}"
REGION="eu-west-2"

if [ -z "$INSTANCE_NAME" ]; then
  echo "Usage: $0 <instance-name> [snapshot-time]"
  echo ""
  echo "Example:"
  echo "  $0 my-wordpress-blog 03:00"
  echo ""
  echo "Snapshot time format: HH:MM (24-hour UTC)"
  exit 1
fi

echo "Enabling automatic snapshots..."
echo "  Instance: $INSTANCE_NAME"
echo "  Time: $SNAPSHOT_TIME UTC"
echo "  Region: $REGION"
echo ""

# Enable automatic snapshots
aws lightsail enable-add-on \
  --resource-name "$INSTANCE_NAME" \
  --add-on-request "addOnType=AutoSnapshot,autoSnapshotAddOnRequest={snapshotTimeOfDay=$SNAPSHOT_TIME}" \
  --region "$REGION"

echo ""
echo "Automatic snapshots enabled successfully!"
echo ""
echo "Configuration:"
echo "  - Daily snapshots at $SNAPSHOT_TIME UTC"
echo "  - 7-day retention"
echo ""
echo "Run './scripts/verify-backups.sh $INSTANCE_NAME' to verify snapshots."
