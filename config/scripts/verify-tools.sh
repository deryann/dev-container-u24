#!/bin/bash

# Tool verification script
echo "=== Development Tools Verification ==="

# Check Python version
echo -n "Python: "
python --version 2>&1 | grep -o "Python [0-9.]*"

# Check system tools
echo -n "Git: "
git --version 2>&1 | grep -o "git version [0-9.]*"

echo -n "ZSH: "
zsh --version 2>&1 | grep -o "zsh [0-9.]*"

echo -n "JQ: "
jq --version 2>&1

echo -n "Net-tools (netstat): "
netstat --version 2>&1 | head -1 | grep -o "net-tools [0-9.]*" || echo "Available"

echo -n "LFTP: "
lftp --version 2>&1 | head -1 | grep -o "LFTP | Version [0-9.]*" || echo "Available"

echo -n "Moreutils (sponge): "
which sponge > /dev/null && echo "Available" || echo "Not found"

# Check special download tools
echo -n "Ripgrep: "
rg --version 2>&1 | head -1

echo -n "Bat: "
bat --version 2>&1 | head -1

echo -n "Btop: "
btop --version 2>&1 | head -1 || echo "Available"

echo -n "YQ: "
yq --version 2>&1

# Check Rust and UV
echo -n "Rust: "
rustc --version 2>&1 | grep -o "rustc [0-9.]*"

echo -n "UV: "
uv --version 2>&1

echo "=== All tools verification completed ==="