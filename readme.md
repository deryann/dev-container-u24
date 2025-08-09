# Python Development Environment

A clean Python development container with Bash and essential development tools.

## ✨ Features

- **Python 3.11** with uv package manager
- **Bash** shell environment
- **Development Tools**: ripgrep, bat, btop, yq, jq
- **Enhanced Commands**: Smart aliases for better productivity

## 🚀 Quick Start

```bash
# Copy environment configuration
cp .env.example .env

# Customize your configuration in .env file
# Edit CONTAINER_NAME, HOST_WORK_DIR, SSH_PORT, SSH_USER, SSH_PASSWORD as needed

# Build and start
docker compose up -d --build

# Enter development environment
docker compose exec python-dev bash

# Check environment health
docker compose exec python-dev env-check
```

## 🔐 SSH Access

The container automatically starts SSH service with configurable credentials:

### Configuration

First, copy the example environment file and customize it:

```bash
cp .env.example .env
```

Edit `.env` file to configure your environment:

```bash
# Container configuration
CONTAINER_NAME=python-dev-container  # Container name (customize as needed)

# Volume mount - specify your local work directory
HOST_WORK_DIR=./                    # Current directory (default)
# HOST_WORK_DIR=/path/to/your/code  # Or absolute path

# SSH Configuration
SSH_PORT=2222           # External SSH port
SSH_USER=developer      # SSH username  
SSH_PASSWORD=dev123456  # SSH password (change this!)
```

### Connect via SSH

```bash
# Connect to container via SSH
ssh -p 2222 developer@localhost

# Test SSH connection
docker compose exec python-dev test-ssh
```

The SSH user has full sudo privileges within the container.

## 🛠️ Available Tools & Enhanced Aliases

### Enhanced Command Aliases

- `cat` → `bat` - Syntax highlighting & line numbers
- `grep` → `rg` - Faster search with better output
- `top` → `btop` - Modern system monitor
- `pip` → `uv pip` - Faster package manager
- `pip3` → `uv pip` - Faster package manager

### Additional Tools

- `vim` - Text editor
- `yq` - YAML/JSON processor
- `jq` - JSON processor
- Standard `ls` aliases: `ll`, `la`, `l`

### Accessing Original Commands

If you need the original command behavior:

```bash
command cat file.txt    # Use original cat
command grep pattern    # Use original grep
command top            # Use original top
```

## 🔧 Shell Configuration

The container uses Bash with useful aliases and environment settings:

- Standard aliases: `ll`, `la`, `l`
- Development tool aliases: `cat`→`bat`, `grep`→`rg`, `top`→`btop`
- Python environment configured with UV
- Git integration and color output

## 📁 Project Structure

```
├── Dockerfile              # Container definition
├── docker-compose.yml      # Service configuration
├── config/
│   └── scripts/            # Utility scripts
└── README.md
```

## 📋 Utility Commands

- `env-check` - Environment health check
- `fallback-shell` - Basic shell fallback
- `test-ssh` - Test SSH connection configuration
- `ssh-setup` - Initialize SSH service (runs automatically)
