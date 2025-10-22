#!/bin/bash
set -e

# Daily health check for Lightsail WordPress instance
# Usage: ./daily-health-check.sh <instance-name>

INSTANCE_NAME="${1}"
REGION="eu-west-2"

if [ -z "$INSTANCE_NAME" ]; then
  echo "Usage: $0 <instance-name>"
  echo ""
  echo "Example:"
  echo "  $0 my-wordpress-blog"
  exit 1
fi

echo "=========================================="
echo "WordPress Instance Health Check"
echo "Instance: $INSTANCE_NAME"
echo "Date: $(date)"
echo "=========================================="
echo ""

# Check instance state
echo "Instance State:"
STATE=$(aws lightsail get-instance-state \
  --instance-name "$INSTANCE_NAME" \
  --region "$REGION" \
  --query "state.name" \
  --output text)
echo "  Status: $STATE"
echo ""

# Check CPU metrics (last hour)
echo "CPU Utilization (Last Hour):"
aws lightsail get-instance-metric-data \
  --instance-name "$INSTANCE_NAME" \
  --metric-name CPUUtilization \
  --period 3600 \
  --start-time "$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S)" \
  --end-time "$(date -u +%Y-%m-%dT%H:%M:%S)" \
  --unit Percent \
  --statistics Average \
  --region "$REGION" \
  --query "metricData[0].average" \
  --output text | awk '{printf "  Average: %.2f%%\n", $1}'
echo ""

# Check network metrics (last hour)
echo "Network Traffic (Last Hour):"
NETWORK_IN=$(aws lightsail get-instance-metric-data \
  --instance-name "$INSTANCE_NAME" \
  --metric-name NetworkIn \
  --period 3600 \
  --start-time "$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S)" \
  --end-time "$(date -u +%Y-%m-%dT%H:%M:%S)" \
  --unit Bytes \
  --statistics Sum \
  --region "$REGION" \
  --query "metricData[0].sum" \
  --output text)

NETWORK_OUT=$(aws lightsail get-instance-metric-data \
  --instance-name "$INSTANCE_NAME" \
  --metric-name NetworkOut \
  --period 3600 \
  --start-time "$(date -u -d '1 hour ago' +%Y-%m-%dT%H:%M:%S)" \
  --end-time "$(date -u +%Y-%m-%dT%H:%M:%S)" \
  --unit Bytes \
  --statistics Sum \
  --region "$REGION" \
  --query "metricData[0].sum" \
  --output text)

echo "  Network In: $(echo "$NETWORK_IN" | awk '{printf "%.2f MB", $1/1024/1024}')"
echo "  Network Out: $(echo "$NETWORK_OUT" | awk '{printf "%.2f MB", $1/1024/1024}')"
echo ""

echo "=========================================="
echo "Health check complete"
echo "=========================================="
