#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-eu-west-2"
REGION="eu-west-2"
MAX_SNAPSHOTS=7

echo "=== Backup Verification Report ==="
echo "Instance: $INSTANCE_NAME"
echo "Region: $REGION"
echo "Timestamp: $(date)"
echo ""

# Get recent snapshots
echo "=== Recent Snapshots (Last $MAX_SNAPSHOTS) ==="
SNAPSHOTS=$(aws lightsail get-instance-snapshots \
  --region "$REGION" \
  --query "instanceSnapshots[?fromInstanceName=='$INSTANCE_NAME'] | sort_by(@, &createdAt) | reverse(@) | [0:$MAX_SNAPSHOTS]" \
  --output json)

# Check if snapshots exist
SNAPSHOT_COUNT=$(echo "$SNAPSHOTS" | jq 'length')

if [[ "$SNAPSHOT_COUNT" -eq 0 ]]; then
  echo "⚠ WARNING: No snapshots found!"
  echo ""
  echo "Action required: Enable automatic snapshots with './scripts/enable-snapshots.sh'"
  exit 1
fi

echo "Total snapshots found: $SNAPSHOT_COUNT"
echo ""

# Display snapshot details
echo "$SNAPSHOTS" | jq -r '.[] | "Name: \(.name)\nCreated: \(.createdAt)\nState: \(.state)\nSize: \(.sizeInGb) GB\n"'

# Check for recent snapshots (within last 48 hours)
RECENT_SNAPSHOT=$(echo "$SNAPSHOTS" | jq -r '.[0].createdAt')
RECENT_TIMESTAMP=$(date -d "$RECENT_SNAPSHOT" +%s 2>/dev/null || echo "0")
CURRENT_TIMESTAMP=$(date +%s)
HOURS_SINCE_LAST=$((($CURRENT_TIMESTAMP - $RECENT_TIMESTAMP) / 3600))

echo "=== Backup Status ==="
echo "Most recent snapshot: $RECENT_SNAPSHOT"
echo "Hours since last backup: $HOURS_SINCE_LAST"
echo ""

if [[ $HOURS_SINCE_LAST -gt 48 ]]; then
  echo "⚠ WARNING: No recent backups! Last backup was $HOURS_SINCE_LAST hours ago."
  echo "Action required: Check automatic snapshot configuration."
else
  echo "✓ Backups are current"
fi

echo ""
echo "=== Verification Complete ==="
