# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Environment Overview

This is a Python development container environment built on Docker with enhanced development tools, ZSH with Powerlevel10k, and SSH access capabilities. The environment is designed for Python development with modern tooling and enhanced terminal experience.

## Key Commands

### Container Management
```bash
# Start the development environment
docker compose up -d --build

# Enter the development container
docker compose exec python-dev zsh

# Health check the environment
docker compose exec python-dev env-check
```

### Environment Configuration
```bash
# First-time setup: copy and customize environment file
cp .env.example .env
# Edit .env to configure CONTAINER_NAME, HOST_WORK_DIR, SSH_PORT, SSH_USER, SSH_PASSWORD

# Configure Powerlevel10k theme (interactive wizard)
p10k configure
```

### SSH Access
```bash
# Connect via SSH (using configured port and credentials from .env)
ssh -p 2222 developer@localhost

# Test SSH configuration
docker compose exec python-dev test-ssh
```

### Python Development
```bash
# Python package management (uses UV internally)
pip install package_name
pip3 install package_name

# Check Python environment
python-check

# Environment health check
env-check
health-check
```

## Architecture and Structure

### Container Architecture
- **Base**: Python 3.11-slim with essential development tools
- **Shell**: ZSH with Oh My Zsh, Powerlevel10k theme, and enhanced plugins
- **Package Manager**: UV (aliased to pip/pip3 for familiar usage)
- **Enhanced Tools**: ripgrep (rg), bat, btop, yq, jq with smart aliasing
- **SSH Server**: Configurable SSH access with sudo privileges

### Directory Structure
```
├── Dockerfile              # Multi-stage Python development container
├── docker-compose.yml      # Service configuration with environment variables
├── config/
│   ├── scripts/            # Utility scripts (env-check, ssh-setup, etc.)
│   └── zsh/                # ZSH and Powerlevel10k configurations
└── readme.md              # Comprehensive setup and usage documentation
```

### Tool Aliases and Enhancements
The environment includes smart command aliases that enhance common development tools:
- `cat` → `bat` (syntax highlighting)
- `grep` → `rg` (ripgrep - faster search)
- `top` → `btop` (modern system monitor)  
- `pip` → `uv pip` (faster package manager)
- `pip3` → `uv pip` (faster package manager)

Original commands can be accessed using `command <original-tool>` if needed.

### Environment Variables
Key environment variables configured in docker-compose.yml:
- `PYTHONPATH=/app` (working directory mounted as volume)
- `PYTHONDONTWRITEBYTECODE=1` (prevent .pyc files)
- `PYTHONUNBUFFERED=1` (real-time output)
- `SHELL=/bin/zsh` (enhanced shell experience)

### Utility Scripts
Available system scripts (accessible from PATH):
- `env-check` - Comprehensive environment health check
- `ssh-setup` - Initialize SSH service (runs automatically)
- `test-ssh` - Test SSH connection configuration
- `fallback-shell` - Basic shell fallback if ZSH fails
- `test-terminal` - Terminal output testing

## Development Workflow

1. **Initial Setup**: Copy `.env.example` to `.env` and customize configuration
2. **Container Startup**: Use `docker compose up -d --build` to start
3. **Environment Entry**: Use `docker compose exec python-dev zsh` or SSH connection
4. **First-time Configuration**: Run `p10k configure` to set up terminal theme
5. **Development**: Work in `/app` directory (mapped to host filesystem)
6. **Health Monitoring**: Use `env-check` to verify environment state

## Network and Ports

- **SSH Port**: Configurable via `SSH_PORT` in .env (default: 2222)
- **Network**: Custom bridge network (`app-net`) for container isolation
- **Volume Mount**: Host work directory mapped to `/app` in container

## SSH and Security

- SSH server runs automatically on container startup
- SSH user configured via environment variables with sudo privileges  
- SSH keys can be mounted from host `~/.ssh` directory (read-only)
- Password authentication available for development convenience