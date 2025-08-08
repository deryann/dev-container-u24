# Python Development Environment

A clean Python development container with ZSH, Powerlevel10k, and essential development tools.

## ✨ Features

- **Python 3.11** with uv package manager
- **ZSH** with Oh My Zsh and Powerlevel10k theme
- **Development Tools**: ripgrep, bat, btop, yq, jq
- **Enhanced Terminal**: Auto-suggestions, syntax highlighting, smart directory jumping

## 🚀 Quick Start

```bash
# Copy environment configuration
cp .env.example .env

# Customize your configuration in .env file
# Edit CONTAINER_NAME, HOST_WORK_DIR, SSH_PORT, SSH_USER, SSH_PASSWORD as needed

# Build and start
docker compose up -d --build

# Enter development environment
docker compose exec python-dev zsh

# Configure Powerlevel10k theme (first time setup)
p10k configure

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

## ⚡ Powerlevel10k Configuration

### First Time Setup

When you first enter the container, run the configuration wizard:

```bash
p10k configure
```

This interactive wizard will help you:

- Choose your preferred prompt style
- Configure icons and symbols
- Set up Git integration
- Customize colors and layout

### Reconfigure Anytime

You can reconfigure your prompt at any time:

```bash
p10k configure    # Run configuration wizard again
```

### Manual Configuration

The configuration is stored in `~/.p10k.zsh`. You can:

- Edit this file directly for advanced customization
- Backup your configuration for reuse
- Share configurations between containers

## 📁 Project Structure

```
├── Dockerfile              # Container definition
├── docker-compose.yml      # Service configuration
├── config/
│   ├── zsh/                # ZSH configuration
│   └── scripts/            # Utility scripts
└── README.md
```

## 📋 Utility Commands

- `env-check` - Environment health check
- `fallback-shell` - Basic shell if ZSH fails
- `test-ssh` - Test SSH connection configuration
- `ssh-setup` - Initialize SSH service (runs automatically)
