#!/bin/bash

# SSH Setup Script for Docker Container
echo "🔐 Setting up SSH service..."

# Generate SSH host keys if they don't exist
if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
    ssh-keygen -A
fi

# Create SSH user if specified
if [ -n "$SSH_USER" ] && [ -n "$SSH_PASSWORD" ]; then
    # Create user with home directory
    useradd -m -s /bin/bash "$SSH_USER"
    
    # Set password
    echo "$SSH_USER:$SSH_PASSWORD" | chpasswd
    
    # Add user to sudo group for root privileges
    usermod -aG sudo "$SSH_USER"
    
    # Configure complete development environment for SSH user
    cat <<'BASHRC_EOF' >> "/home/$SSH_USER/.bashrc"

# Essential aliases
alias ll="ls -alF"
alias la="ls -A"
alias l="ls -CF"

# Development environment paths
export PATH="/opt/rust/bin:/usr/bin:/usr/local/bin:$PATH"
export STARSHIP_CONFIG="/etc/starship/starship.toml"

# Load fzf if available
[ -f /opt/fzf/shell/completion.bash ] && source /opt/fzf/shell/completion.bash
[ -f /opt/fzf/shell/key-bindings.bash ] && source /opt/fzf/shell/key-bindings.bash

# Enhanced command aliases
alias cat='bat --style=auto --paging=never'
alias grep='rg --color=auto'
alias top='btop'
alias pip='uv pip'
alias pip3='uv pip'

# Fallback aliases to access original commands if needed
alias original_cat='/bin/cat'
alias original_grep='/bin/grep'
alias original_top='/usr/bin/top'
alias original_pip='/usr/bin/pip3'

# Yazi function for directory navigation
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# Initialize Starship prompt
eval "$(starship init bash)"
BASHRC_EOF
    
    # Create symbolic links for convenience
    sudo -u "$SSH_USER" ln -sf /app "/home/$SSH_USER/app"
    # Create projects directory owned by SSH_USER instead of linking to /opt/projects
    sudo -u "$SSH_USER" mkdir -p "/home/$SSH_USER/projects"
    sudo chown "$SSH_USER:$SSH_USER" "/home/$SSH_USER/projects"
    
    # Create user config directories
    sudo -u "$SSH_USER" mkdir -p "/home/$SSH_USER/.config"
    
    # Copy Starship config to user directory
    if [ -f /etc/starship/starship.toml ]; then
        sudo -u "$SSH_USER" cp /etc/starship/starship.toml "/home/$SSH_USER/.config/starship.toml"
    fi
    
    # Create Yazi config directory and copy system config if it exists
    sudo -u "$SSH_USER" mkdir -p "/home/$SSH_USER/.config/yazi"
    if [ -f /etc/yazi/theme.toml ]; then
        sudo -u "$SSH_USER" cp /etc/yazi/theme.toml "/home/$SSH_USER/.config/yazi/theme.toml"
    fi
    
    # Set proper ownership
    chown -R "$SSH_USER:$SSH_USER" "/home/$SSH_USER"
    
    # Give user write permissions to /app directory
    chown -R "$SSH_USER:$SSH_USER" /app
    chmod -R 755 /app
    
    # Add user to root group for additional permissions
    usermod -aG root "$SSH_USER"
    
    # Run the user environment setup script
    setup-user-env "$SSH_USER"
    
    echo "✅ SSH user '$SSH_USER' created with sudo privileges and /app access (using bash shell)"
fi

# Configure SSH daemon
cat > /etc/ssh/sshd_config << EOF
Port 22
PermitRootLogin yes
PasswordAuthentication yes
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
ChallengeResponseAuthentication no
UsePAM yes
X11Forwarding yes
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server
EOF

# Start SSH service
service ssh start

echo "✅ SSH service started on port 22"