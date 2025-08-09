#!/bin/bash

# Enhanced Python Development Environment Check Script
echo "Enhanced Python Development Environment - Health Check"
echo "========================================================"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check command and version
check_command() {
    local cmd=$1
    local expected_pattern=$2
    local description=$3
    
    echo -n "Checking $description... "
    
    if command -v "$cmd" >/dev/null 2>&1; then
        version_output=$($cmd --version 2>&1 | head -1)
        if [[ -n "$expected_pattern" && ! "$version_output" =~ $expected_pattern ]]; then
            echo -e "${YELLOW}WARNING${NC}: $version_output (unexpected format)"
        else
            echo -e "${GREEN}✓${NC} $version_output"
        fi
    else
        echo -e "${RED}✗${NC} Not found"
        return 1
    fi
}

# Function to check file exists
check_file() {
    local file=$1
    local description=$2
    
    echo -n "Checking $description... "
    
    if [[ -f "$file" ]]; then
        echo -e "${GREEN}✓${NC} Found"
    else
        echo -e "${RED}✗${NC} Not found: $file"
        return 1
    fi
}

# Function to check environment variable
check_env_var() {
    local var_name=$1
    local description=$2
    
    echo -n "Checking $description... "
    
    if [[ -n "${!var_name}" ]]; then
        echo -e "${GREEN}✓${NC} ${!var_name}"
    else
        echo -e "${YELLOW}WARNING${NC}: $var_name not set"
        return 1
    fi
}

echo -e "\n${BLUE}1. System Information${NC}"
echo "Architecture: $(uname -m)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Shell: $SHELL"

echo -e "\n${BLUE}2. Python Environment${NC}"
check_command "python" "Python 3\.11" "Python 3.11"
check_env_var "VIRTUAL_ENV" "Virtual Environment"
check_env_var "PYTHONPATH" "Python Path"

echo -e "\n${BLUE}3. Package Managers${NC}"
check_command "uv" "uv" "UV Package Manager"
check_command "pip" "" "Pip (should be aliased to uv pip)"

echo -e "\n${BLUE}4. Development Tools${NC}"
check_command "git" "git version" "Git"
check_command "vim" "VIM.*version" "Vim"
check_command "rg" "ripgrep" "Ripgrep"
check_command "bat" "bat" "Bat"
check_command "btop" "" "Btop"
check_command "yq" "yq.*version" "YQ"
check_command "jq" "jq" "JQ"

echo -e "\n${BLUE}5. Shell Environment${NC}"
check_command "bash" "GNU bash" "Bash Shell"
check_file "$HOME/.bashrc" "Bash configuration"

echo -e "\n${BLUE}6. Tool Aliases${NC}"
echo -n "Checking aliases... "
source ~/.bashrc >/dev/null 2>&1

aliases_ok=true

# Check key aliases
if ! alias cat 2>/dev/null | grep -q "bat"; then
    echo -e "${YELLOW}WARNING${NC}: cat alias not set to bat"
    aliases_ok=false
fi

if ! alias grep 2>/dev/null | grep -q "rg"; then
    echo -e "${YELLOW}WARNING${NC}: grep alias not set to rg"
    aliases_ok=false
fi

if ! alias top 2>/dev/null | grep -q "btop"; then
    echo -e "${YELLOW}WARNING${NC}: top alias not set to btop"
    aliases_ok=false
fi

if ! alias pip 2>/dev/null | grep -q "uv pip"; then
    echo -e "${YELLOW}WARNING${NC}: pip alias not set to uv pip"
    aliases_ok=false
fi

if $aliases_ok; then
    echo -e "${GREEN}✓${NC} All key aliases configured"
fi

echo -e "\n${BLUE}7. Network and System Tools${NC}"
check_command "netstat" "" "Netstat"
check_command "lftp" "" "LFTP"
check_command "sponge" "" "Sponge (moreutils)"

echo -e "\n${BLUE}8. Rust Environment${NC}"
check_command "rustc" "rustc" "Rust Compiler"
check_command "cargo" "cargo" "Cargo"

echo -e "\n${BLUE}9. Final Environment Test${NC}"
echo -n "Testing Python import... "
if python -c "import sys; print(f'Python {sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')" >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Python imports working"
else
    echo -e "${RED}✗${NC} Python import failed"
fi

echo -n "Testing UV pip... "
if uv pip --version >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} UV pip working"
else
    echo -e "${RED}✗${NC} UV pip failed"
fi

echo -e "\n${GREEN}Environment check completed!${NC}"
echo "If you see any warnings or errors above, please check the installation."