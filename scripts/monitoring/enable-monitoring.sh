#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-us-east-1"
REGION="us-east-1"

echo "Enabling CloudWatch monitoring for instance: $INSTANCE_NAME"
echo ""

# Note: Lightsail instances automatically send metrics to CloudWatch
# This script verifies monitoring is active

echo "Verifying CloudWatch metrics are being collected..."
echo ""

# Get recent CPU utilization metrics
START_TIME=$(date -u -v-1H '+%Y-%m-%dT%H:%M:%S')
END_TIME=$(date -u '+%Y-%m-%dT%H:%M:%S')

aws lightsail get-instance-metric-data \
  --instance-name "$INSTANCE_NAME" \
  --metric-name CPUUtilization \
  --period 300 \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
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
