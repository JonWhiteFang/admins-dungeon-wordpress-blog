#!/bin/bash
set -e

# Get CloudFormation stack outputs
# Usage: ./get-outputs.sh [stack-name]

STACK_NAME="${1:-wordpress-blog-prod}"
REGION="eu-west-2"

echo "Retrieving stack outputs for: $STACK_NAME"
echo ""

aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query "Stacks[0].Outputs" \
  --output table

echo ""
echo "To retrieve your WordPress admin password:"
echo "1. Use the SSH command from the outputs above"
echo "2. Run: cat bitnami_application_password"
