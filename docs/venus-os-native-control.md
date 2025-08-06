# Venus OS Native Relay Control - Documentation

## Overview

This system uses Venus OS native functions exclusively for relay control, eliminating the need for external packages like RpiGpioSetup. Venus OS provides built-in relay management through its MQTT interface and D-Bus system.

## Venus OS Native Relay Control

### MQTT Interface

Venus OS exposes relay control through standardized MQTT topics:

#### Relay Control Topic
```
W/+/relay/1/State
```

#### Message Format
- **Value**: `0` (relay open/off) or `1` (relay closed/on)
- **Data Type**: Integer
- **QoS**: 2 (exactly once delivery)
- **Retained**: false

### Implementation in Node-RED

#### MQTT Out Node Configuration
```json
{
    "type": "mqtt out",
    "name": "Relay 1 Control",
    "topic": "W/+/relay/1/State",
    "qos": "2",
    "retain": "false",
    "broker": "venus-broker"
}
```

#### Control Logic Output
The control logic function outputs:
```javascript
// Send relay control command
var relayMsg = {
    payload: newPumpState ? 1 : 0,  // 1 = close relay (start pump), 0 = open relay (stop pump)
    topic: "relay1"
};
```

## Advantages of Venus OS Native Control

### System Integration
- **Native Support**: Built into Venus OS core system
- **No External Dependencies**: No need for RpiGpioSetup or GPIO packages
- **Automatic Updates**: Compatible with Venus OS updates
- **System Monitoring**: Integrated with Venus OS monitoring

### Reliability and Security
- **D-Bus Backend**: Uses Venus OS internal D-Bus system
- **Error Handling**: Automatic error detection and recovery
- **System Logs**: Integrated logging with Venus OS
- **Permission Management**: Proper access control

### Maintenance Benefits
- **Simplified Setup**: No additional package installation
- **Reduced Complexity**: Fewer components to maintain
- **Better Support**: Supported by Victron Energy
- **Documentation**: Part of official Venus OS documentation

## Migration from GPIO Control

### What Was Removed
- **RpiGpioSetup package**: No longer needed
- **GPIO pin configuration**: Replaced with MQTT topics
- **Hardware dependencies**: Reduced hardware requirements
- **rpi-gpio Node-RED nodes**: Replaced with mqtt out nodes

### What Was Added
- **MQTT relay control**: Venus OS native MQTT interface
- **Built-in reliability**: Venus OS error handling
- **System integration**: Better Venus OS integration
- **Simplified configuration**: Reduced setup complexity

## Testing Venus OS Native Control

### Validation Tests
The system includes comprehensive tests to verify:
1. MQTT relay topic configuration
2. Correct message format (0/1)
3. QoS configuration (exactly once delivery)
4. Removal of GPIO dependencies
5. Proper Node-RED flow structure

### Test Execution
```bash
# Run Venus OS native relay control test
./scripts/test-relay-control.sh

# Run full system validation
./scripts/test-system.sh all
```

## Troubleshooting

### Common Issues

#### Relay Not Responding
1. **Check Venus OS relay configuration**
   ```bash
   # Via Venus OS interface
   Settings > I/O > Digital inputs
   ```

2. **Verify MQTT topic**
   ```bash
   # Monitor MQTT traffic
   mosquitto_sub -h localhost -t "W/+/relay/+/State"
   ```

3. **Test manual control**
   ```bash
   # Manual relay control via MQTT
   mosquitto_pub -h localhost -t "W/$(venus-device-id)/relay/1/State" -m "1"
   ```

#### MQTT Connection Issues
1. **Check Venus OS MQTT broker**
   ```bash
   systemctl status mosquitto
   ```

2. **Verify Node-RED MQTT configuration**
   - Broker: localhost
   - Port: 1883
   - Client ID: (automatic)

### Diagnostic Commands

#### Venus OS System Status
```bash
# Check relay services
dbus -y com.victronenergy.system /Relay/1/State GetValue

# Check MQTT broker
systemctl status mosquitto

# Check Venus OS services
svstat /service/*
```

#### Node-RED Debugging
1. Enable debug nodes in Node-RED flow
2. Monitor debug output for MQTT messages
3. Check Node-RED logs: `journalctl -u nodered -f`

## Best Practices

### Configuration
- Always use QoS 2 for relay control messages
- Set retain to false for state commands
- Use the official Venus OS MQTT broker

### Error Handling
- Implement message validation in Node-RED
- Add logging for relay state changes
- Monitor system health via Venus OS interface

### Maintenance
- Regular Venus OS updates
- Monitor MQTT broker performance
- Check relay operation periodically

## Future Compatibility

### Venus OS Updates
This implementation uses standard Venus OS interfaces that are:
- **Stable**: Part of the official Venus OS API
- **Supported**: Maintained by Victron Energy
- **Future-proof**: Compatible with future Venus OS versions

### Extension Possibilities
- Multiple relay control
- Integration with other Venus OS devices
- Advanced monitoring and analytics
- Remote control via VRM portal

## References

### Official Documentation
- [Venus OS MQTT Documentation](https://github.com/victronenergy/venus/wiki/MQTT-Topics)
- [Venus OS D-Bus Documentation](https://github.com/victronenergy/venus/wiki/dbus)
- [Victron Energy Developer Portal](https://www.victronenergy.com/support-and-downloads/software)

### Related Projects
- [Venus OS GitHub Repository](https://github.com/victronenergy/venus)
- [Node-RED Venus OS Nodes](https://flows.nodered.org/search?term=venus)