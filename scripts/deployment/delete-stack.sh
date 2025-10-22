#!/bin/bash
set -e

# Configuration
STACK_NAME="wordpress-blog-prod"
INSTANCE_NAME="wordpress-blog-prod-eu-west-2"
REGION="eu-west-2"

echo "=== WordPress Stack Deletion ==="
echo "Stack: $STACK_NAME"
echo "Instance: $INSTANCE_NAME"
echo ""
echo "⚠ WARNING: This will delete all resources in the stack!"
echo ""
read -p "Are you sure you want to continue? (yes/no): " CONFIRM

if [[ "$CONFIRM" != "yes" ]]; then
  echo "Deletion cancelled."
  exit 0
fi

echo ""
echo "Creating final backup snapshot before deletion..."

# Create final backup
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
SNAPSHOT_NAME="wordpress-final-backup-${TIMESTAMP}"

aws lightsail create-instance-snapshot \
  --instance-name "$INSTANCE_NAME" \
  --instance-snapshot-name "$SNAPSHOT_NAME" \
  --region "$REGION"

echo "✓ Final backup created: $SNAPSHOT_NAME"
echo ""
echo "Waiting 30 seconds for snapshot to initialize..."
sleep 30

echo ""
echo "Deleting CloudFormation stack..."

# Delete stack
aws cloudformation delete-stack \
  --stack-name "$STACK_NAME" \
  --region "$REGION"

echo ""
echo "Stack deletion initiated. Monitoring status..."
echo ""

# Monitor stack deletion
while true; do
  STATUS=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query "Stacks[0].StackStatus" \
    --output text 2>/dev/null || echo "DELETE_COMPLETE")
  
  if [[ "$STATUS" == "DELETE_COMPLETE" ]]; then
    echo ""
    echo "✓ Stack deleted successfully!"
    break
  elif [[ "$STATUS" == "DELETE_FAILED" ]]; then
    echo ""
    echo "✗ Stack deletion failed!"
    exit 1
  fi
  
  echo "Current status: $STATUS"
  sleep 10
done

echo ""
echo "=== Deletion Complete ==="
echo ""
echo "Final backup snapshot: $SNAPSHOT_NAME"
echo ""
echo "Note: The snapshot is retained and can be used to restore the instance."
echo "To delete the snapshot, run:"
echo "aws lightsail delete-instance-snapshot --instance-snapshot-name $SNAPSHOT_NAME --region $REGION"
