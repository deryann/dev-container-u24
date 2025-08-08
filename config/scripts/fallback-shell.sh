#!/bin/bash

# Fallback shell configuration for when ZSH setup fails
echo "🔧 Fallback Shell Environment"
echo "=============================="

# Basic environment setup
export PYTHONPATH=/app
export PYTHONDONTWRITEBYTECODE=1
export PYTHONUNBUFFERED=1

# Virtual environment setup
if [[ -n "$VIRTUAL_ENV" && -d "$VIRTUAL_ENV" ]]; then
    export PATH="$VIRTUAL_ENV/bin:$PATH"
    echo "✓ Virtual environment activated: $VIRTUAL_ENV"
else
    echo "⚠️  Virtual environment not available"
fi

# Basic aliases (fallback versions)
if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
else
    echo "⚠️  bat not found, using standard cat"
fi

if command -v rg >/dev/null 2>&1; then
    alias grep='rg'
else
    echo "⚠️  ripgrep not found, using standard grep"
fi

if command -v btop >/dev/null 2>&1; then
    alias top='btop'
else
    echo "⚠️  btop not found, using standard top"
fi

if command -v uv >/dev/null 2>&1; then
    alias pip='uv pip'
    alias pip3='uv pip'
else
    echo "⚠️  uv not found, using standard pip"
fi

# Basic prompt
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '

# Useful functions
python-check() {
    echo "Python: $(python --version 2>&1)"
    echo "Pip: $(pip --version 2>&1)"
}

tools-check() {
    echo "Checking available tools..."
    for tool in python git rg bat btop yq jq uv; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "✓ $tool"
        else
            echo "✗ $tool"
        fi
    done
}

echo ""
echo "Available commands:"
echo "  python-check  - Check Python and pip versions"
echo "  tools-check   - Check available development tools"
echo "  env-check     - Run full environment check"
echo ""
echo "To switch to ZSH (if available): exec zsh"