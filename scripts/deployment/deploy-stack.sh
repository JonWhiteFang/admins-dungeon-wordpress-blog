#!/bin/bash
set -e

# Configuration
STACK_NAME="wordpress-blog-prod"
TEMPLATE_FILE="templates/lightsail-wordpress.yaml"
REGION="us-east-1"

# Parameters (customize these)
INSTANCE_NAME="wordpress-blog-prod-us-east-1"
INSTANCE_PLAN="small_2_0"  # Options: micro_2_0, small_2_0, medium_2_0, large_2_0
AVAILABILITY_ZONE="us-east-1b"
ADMIN_EMAIL="jono2411@outlook.com"
DOMAIN_NAME="admin-dungeon.co.uk"  # Leave empty to skip domain configuration
ENABLE_SNAPSHOTS="true"

echo "Deploying WordPress stack: $STACK_NAME"
echo "Instance: $INSTANCE_NAME"
echo "Plan: $INSTANCE_PLAN"
echo "Region: $REGION"
echo ""

# Create CloudFormation stack
aws cloudformation create-stack \
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
echo "Stack creation initiated. Monitoring status..."
echo ""

# Monitor stack creation
while true; do
  STATUS=$(aws cloudformation describe-stacks \
    --stack-name "$STACK_NAME" \
    --region "$REGION" \
    --query "Stacks[0].StackStatus" \
    --output text 2>/dev/null || echo "PENDING")
  
  echo "Current status: $STATUS"
  
  if [[ "$STATUS" == "CREATE_COMPLETE" ]]; then
    echo ""
    echo "✓ Stack created successfully!"
    break
  elif [[ "$STATUS" == "CREATE_FAILED" ]] || [[ "$STATUS" == "ROLLBACK_COMPLETE" ]]; then
    echo ""
    echo "✗ Stack creation failed!"
    exit 1
  fi
  
  sleep 10
done

echo ""
echo "Waiting for stack to be fully ready..."
aws cloudformation wait stack-create-complete \
  --stack-name "$STACK_NAME" \
  --region "$REGION"

echo ""
echo "✓ Deployment complete!"
echo ""
echo "Run './scripts/deployment/get-outputs.sh' to view stack outputs and next steps."
