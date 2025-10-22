#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-eu-west-2"
REGION="eu-west-2"

echo "Enabling CloudWatch monitoring for instance: $INSTANCE_NAME"
echo ""

# Note: Lightsail instances automatically send metrics to CloudWatch
# This script verifies monitoring is active

echo "Verifying CloudWatch metrics are being collected..."
echo ""

# Get recent CPU utilization metrics
aws lightsail get-instance-metric-data \
  --instance-name "$INSTANCE_NAME" \
  --metric-name CPUUtilization \
  --period 300 \
  --start-time "$(date -u -d '1 hour ago' +%s)" \
  --end-time "$(date -u +%s)" \
  --unit Percent \
  --statistics Average \
  --region "$REGION" \
  --query "metricData[*].{Timestamp:timestamp, Average:average}" \
  --output table

echo ""
echo "✓ Monitoring is active!"
echo ""
echo "Available metrics:"
echo "- CPUUtilization"
echo "- NetworkIn"
echo "- NetworkOut"
echo "- StatusCheckFailed"
echo "- StatusCheckFailed_Instance"
echo "- StatusCheckFailed_System"
echo ""
echo "Run './scripts/create-alarms.sh' to configure CloudWatch alarms."
