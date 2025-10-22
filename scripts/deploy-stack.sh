#!/bin/bash
set -e

# Deploy CloudFormation stack for WordPress on Lightsail
# Usage: ./deploy-stack.sh <instance-name> <admin-email> [domain-name] [instance-plan]

INSTANCE_NAME="${1}"
ADMIN_EMAIL="${2}"
DOMAIN_NAME="${3:-}"
INSTANCE_PLAN="${4:-small_2_0}"
STACK_NAME="wordpress-blog-prod"
REGION="eu-west-2"
AVAILABILITY_ZONE="eu-west-2a"

if [ -z "$INSTANCE_NAME" ] || [ -z "$ADMIN_EMAIL" ]; then
  echo "Usage: $0 <instance-name> <admin-email> [domain-name] [instance-plan]"
  echo ""
  echo "Example:"
  echo "  $0 my-wordpress-blog admin@example.com example.com small_2_0"
  echo ""
  echo "Instance plans: micro_2_0, small_2_0, medium_2_0, large_2_0"
  exit 1
fi

echo "Deploying WordPress stack..."
echo "  Instance Name: $INSTANCE_NAME"
echo "  Admin Email: $ADMIN_EMAIL"
echo "  Domain Name: ${DOMAIN_NAME:-None}"
echo "  Instance Plan: $INSTANCE_PLAN"
echo "  Region: $REGION"
echo ""

# Build parameters
PARAMETERS="ParameterKey=InstanceName,ParameterValue=$INSTANCE_NAME"
PARAMETERS="$PARAMETERS ParameterKey=AdminEmail,ParameterValue=$ADMIN_EMAIL"
PARAMETERS="$PARAMETERS ParameterKey=InstancePlan,ParameterValue=$INSTANCE_PLAN"
PARAMETERS="$PARAMETERS ParameterKey=AvailabilityZone,ParameterValue=$AVAILABILITY_ZONE"
PARAMETERS="$PARAMETERS ParameterKey=EnableAutomaticSnapshots,ParameterValue=true"

if [ -n "$DOMAIN_NAME" ]; then
  PARAMETERS="$PARAMETERS ParameterKey=DomainName,ParameterValue=$DOMAIN_NAME"
fi

# Create stack
aws cloudformation create-stack \
  --stack-name "$STACK_NAME" \
  --template-body file://lightsail-wordpress.yaml \
  --parameters $PARAMETERS \
  --region "$REGION"

echo ""
echo "Stack creation initiated. Waiting for completion..."
echo "This typically takes 5-10 minutes."
echo ""

# Wait for stack creation
aws cloudformation wait stack-create-complete \
  --stack-name "$STACK_NAME" \
  --region "$REGION"

echo ""
echo "Stack created successfully!"
echo ""
echo "Run './scripts/get-outputs.sh' to see your WordPress site details."
