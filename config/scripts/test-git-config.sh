#!/bin/bash

# Test Git Configuration Script
# This script verifies that git configurations are properly set

echo "🧪 Testing Git configuration..."

# Function to test git config for a specific user
test_user_git_config() {
    local user_name="$1"
    echo "📋 Testing Git config for user: $user_name"
    
    # Test submodule.recurse configuration (the main addition)
    local submodule_config
    if command -v sudo >/dev/null 2>&1 && [ "$user_name" != "$(whoami)" ]; then
        submodule_config=$(sudo -u "$user_name" git config --global --get submodule.recurse 2>/dev/null)
    else
        submodule_config=$(git config --global --get submodule.recurse 2>/dev/null)
    fi
    
    if [ "$submodule_config" = "true" ]; then
        echo "✅ submodule.recurse is correctly set to true for $user_name"
    else
        echo "❌ submodule.recurse is not set to true for $user_name (got: '$submodule_config')"
        return 1
    fi
    
    # Test other basic configurations
    local core_autocrlf
    if command -v sudo >/dev/null 2>&1 && [ "$user_name" != "$(whoami)" ]; then
        core_autocrlf=$(sudo -u "$user_name" git config --global --get core.autocrlf 2>/dev/null)
    else
        core_autocrlf=$(git config --global --get core.autocrlf 2>/dev/null)
    fi
    
    if [ "$core_autocrlf" = "input" ]; then
        echo "✅ core.autocrlf is correctly set to input for $user_name"
    else
        echo "⚠️  core.autocrlf is not set to input for $user_name (got: '$core_autocrlf')"
    fi
}

# Test for current user
current_user=$(whoami)
test_user_git_config "$current_user"
test_result=$?

# Test for root if we're not root and sudo is available
if [ "$current_user" != "root" ] && command -v sudo >/dev/null 2>&1; then
    if id root >/dev/null 2>&1; then
        echo ""
        test_user_git_config "root"
        root_result=$?
        test_result=$((test_result + root_result))
    fi
fi

# Test for developer user if it exists and we're not that user
if [ "$current_user" != "developer" ] && id "developer" >/dev/null 2>&1; then
    echo ""
    test_user_git_config "developer"
    dev_result=$?
    test_result=$((test_result + dev_result))
fi

echo ""
if [ $test_result -eq 0 ]; then
    echo "🎉 All git configuration tests passed!"
    exit 0
else
    echo "❌ Some git configuration tests failed!"
    exit 1
fi