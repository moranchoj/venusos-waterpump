#!/bin/bash

# Test script to verify Venus OS native relay control
# This script validates the MQTT relay control topic and format

FLOW_FILE="$(dirname "$0")/../flows/water-pump-control.json"

echo "=== Venus OS Native Relay Control Test ==="
echo ""

# Test 1: Verify MQTT relay control topic
echo "1. Testing MQTT relay control topic..."
if grep -q "W/+/relay/1/State" "$FLOW_FILE"; then
    echo "✓ Venus OS relay topic found: W/+/relay/1/State"
else
    echo "✗ Venus OS relay topic NOT found"
    exit 1
fi

# Test 2: Verify MQTT out node type
echo "2. Testing MQTT output node..."
if grep -q '"type": "mqtt out"' "$FLOW_FILE"; then
    echo "✓ MQTT out node found"
else
    echo "✗ MQTT out node NOT found"
    exit 1
fi

# Test 3: Verify no GPIO dependencies
echo "3. Testing for GPIO dependencies..."
if grep -q "rpi-gpio" "$FLOW_FILE"; then
    echo "✗ GPIO dependencies still found"
    exit 1
else
    echo "✓ No GPIO dependencies found"
fi

# Test 4: Verify control logic output format
echo "4. Testing relay control output format..."
if grep -q "newPumpState ? 1 : 0" "$FLOW_FILE"; then
    echo "✓ Correct relay control format (0/1)"
else
    echo "✗ Incorrect relay control format"
    exit 1
fi

# Test 5: Verify QoS setting
echo "5. Testing MQTT QoS configuration..."
if grep -A 5 '"type": "mqtt out"' "$FLOW_FILE" | grep -q '"qos": "2"'; then
    echo "✓ QoS 2 configured for reliable delivery"
else
    echo "✗ QoS not properly configured"
    exit 1
fi

echo ""
echo "=== All Venus OS Native Relay Tests Passed! ==="
echo ""
echo "Summary:"
echo "- Venus OS native MQTT relay control: ENABLED"
echo "- GPIO dependencies: REMOVED"
echo "- Relay topic: W/+/relay/1/State"
echo "- Control values: 0 (off) / 1 (on)"
echo "- QoS: 2 (exactly once delivery)"
echo ""