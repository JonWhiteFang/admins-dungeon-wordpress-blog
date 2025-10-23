#!/bin/bash
set -e

# Configuration
STACK_NAME="wordpress-blog-prod"
TEMPLATE_FILE="templates/lightsail-wordpress.yaml"
REGION="us-east-1"

# Parameters (customize these to match your current configuration)
INSTANCE_NAME="wordpress-blog-prod-us-east-1"
INSTANCE_PLAN="small_2_0"
AVAILABILITY_ZONE="us-east-1a"
ADMIN_EMAIL="your-email@example.com"
DOMAIN_NAME=""
ENABLE_SNAPSHOTS="true"

echo "Updating WordPress stack: $STACK_NAME"
echo ""

# Update CloudFormation stack
aws cloudformation update-stack \
  --stack-name "$STACK_NAME" \
  --template-body "file://$TEMPLATE_FILE" \
  --parameters \
    ParameterKey=InstanceName,ParameterValue="$INSTANCE_NAME" \
    ParameterKey=InstancePlan,ParameterValue="$INSTANCE_PLAN" \
    ParameterKey=AvailabilityZone,ParameterValue="$AVAILABILITY_ZONE" \
    ParameterKey=AdminEmail,ParameterValue="$ADMIN_EMAIL" \
    ParameterKey=DomainName,ParameterValue="$DOMAIN_NAME" \
    ParameterKey=EnableAutomaticSnapshots,ParameterValue="$ENABLE_SNAPSHOTS" \
  --region "$REGION"

echo ""
echo "Stack update initiated. Monitoring status..."
echo ""

# Monitor stack update
while true; do
  STATUS=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query "Stacks[0].StackStatus" \
    --output text 2>/dev/null || echo "PENDING")
  
  echo "Current status: $STATUS"
  
  if [[ "$STATUS" == "UPDATE_COMPLETE" ]]; then
    echo ""
    echo "✓ Stack updated successfully!"
    break
  elif [[ "$STATUS" == "UPDATE_FAILED" ]] || [[ "$STATUS" == "UPDATE_ROLLBACK_COMPLETE" ]]; then
    echo ""
    echo "✗ Stack update failed!"
    exit 1
  fi
  
  sleep 10
done

echo ""
echo "✓ Update complete!"
