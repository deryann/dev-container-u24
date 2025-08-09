#!/bin/bash

# Setup User Environment Script
# This script ensures all development tools are available to any user

USERNAME="$1"
USER_HOME="/home/$USERNAME"

if [ -z "$USERNAME" ]; then
    echo "Usage: $0 <username>"
    exit 1
fi

echo "🔧 Setting up development environment for user: $USERNAME"

# Create user directories
mkdir -p "$USER_HOME/.config"
mkdir -p "$USER_HOME/.local/bin"

# Copy system configurations to user directory
if [ -f /etc/starship/starship.toml ]; then
    cp /etc/starship/starship.toml "$USER_HOME/.config/starship.toml"
    echo "✅ Starship config copied"
fi

if [ -d /etc/yazi ]; then
    cp -r /etc/yazi "$USER_HOME/.config/"
    echo "✅ Yazi config copied"
fi

# Set proper ownership
chown -R "$USERNAME:$USERNAME" "$USER_HOME/.config"
chown -R "$USERNAME:$USERNAME" "$USER_HOME/.local"

echo "✅ User environment setup completed for $USERNAME"