#!/bin/bash
set -e

# Configuration
STACK_NAME="wordpress-blog-prod"
REGION="us-east-1"
OUTPUT_FILE="exported-template.yaml"

echo "Exporting CloudFormation template for stack: $STACK_NAME"
echo ""

# Get template from CloudFormation
aws cloudformation get-template \
  --stack-name "$STACK_NAME" \
  --region "$REGION" \
  --query "TemplateBody" \
  --output text > "$OUTPUT_FILE"

echo "✓ Template exported successfully!"
echo ""
echo "Output file: $OUTPUT_FILE"
echo ""
echo "You can use this template to:"
echo "1. Review the current stack configuration"
echo "2. Create a new stack with the same configuration"
echo "3. Compare with your source template"
