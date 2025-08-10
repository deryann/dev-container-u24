#!/bin/bash

# Git Configuration Setup Script
# This script configures Git with environment variables for all users

echo "🔧 Setting up Git configuration..."

# Function to setup git config for a specific user
setup_user_git_config() {
    local user_home="$1"
    local user_name="$2"
    
    echo "📁 Setting up Git config for user: $user_name (home: $user_home)"
    
    # Set Git configuration if environment variables are provided
    if [ -n "$GITHUB_NAME" ]; then
        sudo -u "$user_name" git config --global user.name "$GITHUB_NAME"
        echo "✅ Git user.name set to: $GITHUB_NAME for $user_name"
    else
        echo "⚠️  GITHUB_NAME not set, skipping user.name configuration for $user_name"
    fi

    if [ -n "$GITHUB_EMAIL" ]; then
        sudo -u "$user_name" git config --global user.email "$GITHUB_EMAIL"
        echo "✅ Git user.email set to: $GITHUB_EMAIL for $user_name"
    else
        echo "⚠️  GITHUB_EMAIL not set, skipping user.email configuration for $user_name"
    fi

    # Set Git global configurations
    sudo -u "$user_name" git config --global core.autocrlf input
    echo "✅ Git core.autocrlf set to input for $user_name"

    sudo -u "$user_name" git config --global init.defaultBranch main
    echo "✅ Git init.defaultBranch set to main for $user_name"

    sudo -u "$user_name" git config --global credential.helper store
    echo "✅ Git credential.helper set to store for $user_name"

    # Add GITHUB_TOKEN to user's bashrc if provided
    if [ -n "$GITHUB_TOKEN" ]; then
        local bashrc_file="$user_home/.bashrc"
        # Create .bashrc if it doesn't exist
        if [ ! -f "$bashrc_file" ]; then
            touch "$bashrc_file"
            chown "$user_name:$user_name" "$bashrc_file"
        fi
        
        # Check if GITHUB_TOKEN is already in bashrc
        if ! grep -q "export GITHUB_TOKEN=" "$bashrc_file"; then
            echo "export GITHUB_TOKEN=$GITHUB_TOKEN" >> "$bashrc_file"
            echo "✅ GITHUB_TOKEN added to $bashrc_file"
        else
            # Update existing GITHUB_TOKEN
            sed -i "s/export GITHUB_TOKEN=.*/export GITHUB_TOKEN=$GITHUB_TOKEN/" "$bashrc_file"
            echo "✅ GITHUB_TOKEN updated in $bashrc_file"
        fi
        
        # Add GitHub environment variables to bashrc
        if ! grep -q "export GITHUB_NAME=" "$bashrc_file"; then
            echo "export GITHUB_NAME=$GITHUB_NAME" >> "$bashrc_file"
            echo "export GITHUB_EMAIL=$GITHUB_EMAIL" >> "$bashrc_file"
            echo "✅ GitHub environment variables added to $bashrc_file"
        else
            sed -i "s/export GITHUB_NAME=.*/export GITHUB_NAME=$GITHUB_NAME/" "$bashrc_file"
            sed -i "s/export GITHUB_EMAIL=.*/export GITHUB_EMAIL=$GITHUB_EMAIL/" "$bashrc_file"
            echo "✅ GitHub environment variables updated in $bashrc_file"
        fi
        
        chown "$user_name:$user_name" "$bashrc_file"
    else
        echo "⚠️  GITHUB_TOKEN not set, skipping token configuration for $user_name"
    fi
}

# Setup for root user
setup_user_git_config "/root" "root"

# Setup for developer user if it exists
if id "developer" &>/dev/null; then
    setup_user_git_config "/home/developer" "developer"
else
    echo "ℹ️  Developer user not found, skipping developer configuration"
fi

# Setup for SSH_USER if it exists and is different from developer
if [ -n "$SSH_USER" ] && [ "$SSH_USER" != "developer" ] && id "$SSH_USER" &>/dev/null; then
    setup_user_git_config "/home/$SSH_USER" "$SSH_USER"
else
    echo "ℹ️  SSH_USER not set or same as developer, skipping additional SSH_USER configuration"
fi

echo "🎉 Git configuration setup completed for all users!"