#!/bin/bash
set -e

# Configuration
INSTANCE_NAME="wordpress-blog-prod-us-east-1"
REGION="us-east-1"

echo "=== WordPress Instance Health Check ==="
echo "Instance: $INSTANCE_NAME"
echo "Region: $REGION"
echo "Timestamp: $(date)"
echo ""

# Check instance state
echo "=== Instance State ==="
INSTANCE_STATE=$(aws lightsail get-instance-state \
  --instance-name "$INSTANCE_NAME" \
  --region "$REGION" \
  --query "state.name" \
  --output text)

echo "Status: $INSTANCE_STATE"

if [[ "$INSTANCE_STATE" != "running" ]]; then
  echo "⚠ WARNING: Instance is not running!"
fi

echo ""

# Check CPU utilization (past 1 hour)
echo "=== CPU Utilization (Past 1 Hour) ==="
# macOS/BSD date compatible syntax
START_TIME=$(date -u -v-1H +%s)
END_TIME=$(date -u +%s)
CPU_DATA=$(aws lightsail get-instance-metric-data \
  --instance-name "$INSTANCE_NAME" \
  --metric-name CPUUtilization \
  --period 3600 \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --unit Percent \
  --statistics Average \
  --region "$REGION" \
  --query "metricData[0].average" \
  --output text)

if [[ "$CPU_DATA" != "None" ]] && [[ -n "$CPU_DATA" ]]; then
  echo "Average CPU: ${CPU_DATA}%"
  
  # Check if CPU is high
  if (( $(echo "$CPU_DATA > 80" | bc -l) )); then
    echo "⚠ WARNING: High CPU utilization detected!"
  fi
else
  echo "No CPU data available"
fi

echo ""

# Check network traffic
echo "=== Network Traffic (Past 1 Hour) ==="
NETWORK_IN=$(aws lightsail get-instance-metric-data \
  --instance-name "$INSTANCE_NAME" \
  --metric-name NetworkIn \
  --period 3600 \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --unit Bytes \
  --statistics Sum \
  --region "$REGION" \
  --query "metricData[0].sum" \
  --output text)

NETWORK_OUT=$(aws lightsail get-instance-metric-data \
  --instance-name "$INSTANCE_NAME" \
  --metric-name NetworkOut \
  --period 3600 \
  --start-time "$START_TIME" \
  --end-time "$END_TIME" \
  --unit Bytes \
  --statistics Sum \
  --region "$REGION" \
  --query "metricData[0].sum" \
  --output text)

if [[ "$NETWORK_IN" != "None" ]] && [[ -n "$NETWORK_IN" ]]; then
  NETWORK_IN_MB=$(echo "scale=2; $NETWORK_IN / 1024 / 1024" | bc)
  echo "Network In: ${NETWORK_IN_MB} MB"
else
  echo "Network In: No data available"
fi

if [[ "$NETWORK_OUT" != "None" ]] && [[ -n "$NETWORK_OUT" ]]; then
  NETWORK_OUT_MB=$(echo "scale=2; $NETWORK_OUT / 1024 / 1024" | bc)
  echo "Network Out: ${NETWORK_OUT_MB} MB"
else
  echo "Network Out: No data available"
fi

echo ""
echo "=== Health Check Complete ==="
