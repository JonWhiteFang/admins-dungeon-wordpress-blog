#!/bin/bash
set -e

# Configuration
TEMPLATE_FILE="templates/lightsail-wordpress.yaml"

echo "Validating CloudFormation template: $TEMPLATE_FILE"
echo ""

# Validate template
VALIDATION_OUTPUT=$(aws cloudformation validate-template \
  --template-body "file://$TEMPLATE_FILE" 2>&1)

VALIDATION_STATUS=$?

if [[ $VALIDATION_STATUS -eq 0 ]]; then
  echo "✓ Template is valid!"
  echo ""
  echo "Template details:"
  echo "$VALIDATION_OUTPUT" | jq -r '.Description'
  echo ""
  echo "Parameters:"
  echo "$VALIDATION_OUTPUT" | jq -r '.Parameters[] | "  - \(.ParameterKey): \(.Description)"'
else
  echo "✗ Template validation failed!"
  echo ""
  echo "$VALIDATION_OUTPUT"
  exit 1
fi
