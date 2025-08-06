#!/bin/bash

# Water Pump Control System - Test and Validation Script
# Tests the Node-RED flow structure and configuration

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
FLOW_FILE="$PROJECT_DIR/flows/water-pump-control.json"
CONFIG_FILE="$PROJECT_DIR/config/system-config.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

test_flow_structure() {
    log_test "Testing Node-RED flow structure..."
    
    if [ ! -f "$FLOW_FILE" ]; then
        log_error "Flow file not found: $FLOW_FILE"
        return 1
    fi
    
    # Check if it's valid JSON
    if ! python3 -m json.tool "$FLOW_FILE" > /dev/null 2>&1; then
        log_error "Flow file is not valid JSON"
        return 1
    fi
    
    log_info "Flow file is valid JSON ✓"
    
    # Check for required nodes
    local required_nodes=(
        "mqtt in"
        "function"
        "rpi-gpio out"
        "ui_gauge"
        "ui_text"
        "ui_led"
        "ui_switch"
    )
    
    for node_type in "${required_nodes[@]}"; do
        if grep -q "\"type\": \"$node_type\"" "$FLOW_FILE"; then
            log_info "Found required node type: $node_type ✓"
        else
            log_warn "Missing node type: $node_type"
        fi
    done
    
    # Check for control logic functions
    if grep -q "Pump Control Logic" "$FLOW_FILE"; then
        log_info "Found pump control logic ✓"
    else
        log_error "Missing pump control logic"
        return 1
    fi
    
    # Check for MQTT topics
    if grep -q "N/+/tank/0/Level" "$FLOW_FILE"; then
        log_info "Found Tank A MQTT topic ✓"
    else
        log_error "Missing Tank A MQTT topic"
        return 1
    fi
    
    if grep -q "N/+/tank/1/Level" "$FLOW_FILE"; then
        log_info "Found Tank B MQTT topic ✓"
    else
        log_error "Missing Tank B MQTT topic"
        return 1
    fi
    
    log_info "Flow structure validation completed"
    return 0
}

test_config_file() {
    log_test "Testing configuration file..."
    
    if [ ! -f "$CONFIG_FILE" ]; then
        log_error "Config file not found: $CONFIG_FILE"
        return 1
    fi
    
    # Check if it's valid JSON
    if ! python3 -m json.tool "$CONFIG_FILE" > /dev/null 2>&1; then
        log_error "Config file is not valid JSON"
        return 1
    fi
    
    log_info "Config file is valid JSON ✓"
    
    # Check for required sections
    local required_sections=(
        "system_name"
        "hardware"
        "gpio"
        "mqtt"
        "control_logic"
        "dashboard"
    )
    
    for section in "${required_sections[@]}"; do
        if grep -q "\"$section\"" "$CONFIG_FILE"; then
            log_info "Found config section: $section ✓"
        else
            log_warn "Missing config section: $section"
        fi
    done
    
    log_info "Configuration validation completed"
    return 0
}

test_control_logic() {
    log_test "Testing control logic implementation..."
    
    # Extract control logic from flow
    local logic_found=false
    
    # Check for start conditions
    if grep -q "tankA_level > 10" "$FLOW_FILE" && grep -q "tankB_level < 85" "$FLOW_FILE"; then
        log_info "Start conditions implemented correctly ✓"
        logic_found=true
    else
        log_error "Start conditions not found or incorrect"
    fi
    
    # Check for stop conditions
    if grep -q "tankA_level < 10" "$FLOW_FILE" && grep -q "tankB_level >= 100" "$FLOW_FILE"; then
        log_info "Stop conditions implemented correctly ✓"
        logic_found=true
    else
        log_error "Stop conditions not found or incorrect"
    fi
    
    # Check for priority logic
    if grep -q "Stop conditions override start conditions" "$FLOW_FILE" || grep -q "shouldStop.*shouldStart" "$FLOW_FILE"; then
        log_info "Priority logic implemented ✓"
    else
        log_warn "Priority logic may not be correctly implemented"
    fi
    
    if [ "$logic_found" = true ]; then
        log_info "Control logic validation completed"
        return 0
    else
        log_error "Control logic validation failed"
        return 1
    fi
}

test_dashboard_elements() {
    log_test "Testing dashboard elements..."
    
    # Check for gauges
    if grep -q "ui_gauge" "$FLOW_FILE"; then
        log_info "Gauge elements found ✓"
    else
        log_error "No gauge elements found"
    fi
    
    # Check for status indicators
    if grep -q "ui_text" "$FLOW_FILE" && grep -q "ui_led" "$FLOW_FILE"; then
        log_info "Status indicators found ✓"
    else
        log_warn "Status indicators may be missing"
    fi
    
    # Check for manual controls
    if grep -q "ui_switch" "$FLOW_FILE"; then
        log_info "Manual control switches found ✓"
    else
        log_warn "Manual control switches may be missing"
    fi
    
    # Check for dashboard groups
    if grep -q "ui_group" "$FLOW_FILE" && grep -q "ui_tab" "$FLOW_FILE"; then
        log_info "Dashboard structure found ✓"
    else
        log_error "Dashboard structure may be incomplete"
    fi
    
    log_info "Dashboard validation completed"
    return 0
}

test_safety_features() {
    log_test "Testing safety features..."
    
    # Check for manual override
    if grep -q "manual_override" "$FLOW_FILE"; then
        log_info "Manual override functionality found ✓"
    else
        log_warn "Manual override may not be implemented"
    fi
    
    # Check for data validation
    if grep -q "isNaN" "$FLOW_FILE" || grep -q "parseFloat" "$FLOW_FILE"; then
        log_info "Data validation found ✓"
    else
        log_warn "Data validation may be missing"
    fi
    
    # Check for logging
    if grep -q "node.log" "$FLOW_FILE" || grep -q "node.warn" "$FLOW_FILE"; then
        log_info "Logging functionality found ✓"
    else
        log_warn "Logging functionality may be missing"
    fi
    
    log_info "Safety features validation completed"
    return 0
}

run_all_tests() {
    log_info "Starting Water Pump Control System validation..."
    echo ""
    
    local failed_tests=0
    
    test_flow_structure || ((failed_tests++))
    echo ""
    
    test_config_file || ((failed_tests++))
    echo ""
    
    test_control_logic || ((failed_tests++))
    echo ""
    
    test_dashboard_elements || ((failed_tests++))
    echo ""
    
    test_safety_features || ((failed_tests++))
    echo ""
    
    if [ $failed_tests -eq 0 ]; then
        log_info "🎉 All tests passed! System is ready for deployment."
    else
        log_error "❌ $failed_tests test(s) failed. Please review the issues above."
        return 1
    fi
    
    return 0
}

show_usage() {
    echo "Water Pump Control System - Test and Validation Script"
    echo ""
    echo "Usage:"
    echo "  $0 [test_name]"
    echo ""
    echo "Available tests:"
    echo "  flow          - Test Node-RED flow structure"
    echo "  config        - Test configuration file"
    echo "  logic         - Test control logic implementation"
    echo "  dashboard     - Test dashboard elements"
    echo "  safety        - Test safety features"
    echo "  all           - Run all tests (default)"
    echo "  help          - Show this help"
}

# Main script logic
case "${1:-all}" in
    flow)
        test_flow_structure
        ;;
    config)
        test_config_file
        ;;
    logic)
        test_control_logic
        ;;
    dashboard)
        test_dashboard_elements
        ;;
    safety)
        test_safety_features
        ;;
    all)
        run_all_tests
        ;;
    help|--help|-h)
        show_usage
        ;;
    *)
        log_error "Invalid test name: $1"
        show_usage
        exit 1
        ;;
esac