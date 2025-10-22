#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-eu-west-2"
REGION="eu-west-2"
NOTIFICATION_EMAIL="your-email@example.com"  # Update with your email

echo "Creating CloudWatch alarms for instance: $INSTANCE_NAME"
echo "Notification email: $NOTIFICATION_EMAIL"
echo ""

# Create high CPU alarm
echo "Creating high CPU utilization alarm..."
aws lightsail put-alarm \
  --alarm-name "wordpress-high-cpu" \
  --metric-name CPUUtilization \
  --monitored-resource-name "$INSTANCE_NAME" \
  --comparison-operator GreaterThanThreshold \
  --threshold 80 \
  --evaluation-periods 2 \
  --datapoints-to-alarm 2 \
  --treat-missing-data notBreaching \
  --contact-protocols Email \
  --notification-triggers ALARM \
  --notification-enabled \
  --region "$REGION"

echo "✓ High CPU alarm created"
echo ""

# Create status check failed alarm
echo "Creating status check failed alarm..."
aws lightsail put-alarm \
  --alarm-name "wordpress-status-check-failed" \
  --metric-name StatusCheckFailed \
  --monitored-resource-name "$INSTANCE_NAME" \
  --comparison-operator GreaterThanThreshold \
  --threshold 0 \
  --evaluation-periods 2 \
  --datapoints-to-alarm 2 \
  --treat-missing-data notBreaching \
  --contact-protocols Email \
  --notification-triggers ALARM \
  --notification-enabled \
  --region "$REGION"

echo "✓ Status check alarm created"
echo ""

echo "=== Configured Alarms ==="
echo ""
echo "1. wordpress-high-cpu"
echo "   - Triggers when CPU > 80% for 2 consecutive periods"
echo "   - Evaluation period: 5 minutes"
echo ""
echo "2. wordpress-status-check-failed"
echo "   - Triggers when status checks fail"
echo "   - Evaluation period: 5 minutes"
echo ""
echo "✓ Alarm configuration complete!"
echo ""
echo "IMPORTANT: Check your email ($NOTIFICATION_EMAIL) to confirm SNS subscription."
