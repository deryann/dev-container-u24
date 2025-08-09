#!/bin/bash

# Terminal Output Test Script
# Tests for garbled characters and encoding issues

echo "🧪 Testing terminal output compatibility..."
echo "=================================="

# Test basic ASCII characters
echo "✅ Basic ASCII test:"
echo "abcdefghijklmnopqrstuvwxyz"
echo "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
echo "0123456789"
echo "!@#$%^&*()_+-=[]{}|;:,.<>?"

# Test locale settings
echo ""
echo "🌍 Locale information:"
echo "LANG: ${LANG:-not set}"
echo "LC_ALL: ${LC_ALL:-not set}"
echo "TERM: ${TERM:-not set}"

# Test Unicode support
echo ""
echo "🔤 Unicode test:"
if printf "\u2713" 2>/dev/null | grep -q "✓"; then
    echo "✓ Unicode checkmark works"
else
    echo "X Unicode checkmark failed - using ASCII mode"
fi


# Test Bash prompt
echo ""
echo "🐚 Bash prompt test:"
if command -v bash >/dev/null 2>&1; then
    echo "Bash available: $(bash --version | head -1)"
    # Test a simple Bash command
    bash -c 'echo "Bash prompt test: $PS1"' 2>/dev/null || echo "Bash prompt test failed"
else
    echo "Bash not available"
fi

# Test Docker environment
echo ""
echo "🐳 Docker environment:"
if [[ -f /.dockerenv ]]; then
    echo "✅ Running in Docker container"
    echo "Container ID: $(cat /proc/self/cgroup | head -1 | cut -d/ -f3 | cut -c1-12)"
else
    echo "❌ Not running in Docker container"
fi

# Test font rendering
echo ""
echo "🔤 Font rendering test:"
echo "Normal text"
echo -e "\033[1mBold text\033[0m"
echo -e "\033[31mRed text\033[0m"
echo -e "\033[32mGreen text\033[0m"
echo -e "\033[33mYellow text\033[0m"
echo -e "\033[34mBlue text\033[0m"

echo ""
echo "✅ Terminal test complete!"
echo "If you see garbled characters above, the terminal needs ASCII-only mode."