#!/bin/bash

# SSH Connection Test Script
echo "🔐 Testing SSH connection..."

# Read SSH configuration from .env
if [ -f .env ]; then
    source .env
else
    echo "❌ .env file not found"
    exit 1
fi

echo "SSH Configuration:"
echo "  Port: ${SSH_PORT:-2222}"
echo "  User: ${SSH_USER:-developer}"
echo "  Host: localhost"
echo ""

echo "To connect via SSH, use:"
echo "  ssh -p ${SSH_PORT:-2222} ${SSH_USER:-developer}@localhost"
echo ""
echo "Or test connection:"
echo "  ssh -p ${SSH_PORT:-2222} -o ConnectTimeout=5 ${SSH_USER:-developer}@localhost 'echo \"SSH connection successful!\"'"