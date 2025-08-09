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
    
    # Configure bash environment for SSH user
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> "/home/$SSH_USER/.bashrc"
    echo 'alias ll="ls -alF"' >> "/home/$SSH_USER/.bashrc"
    echo 'alias la="ls -A"' >> "/home/$SSH_USER/.bashrc"
    echo 'alias l="ls -CF"' >> "/home/$SSH_USER/.bashrc"
    echo 'alias cat="bat"' >> "/home/$SSH_USER/.bashrc"
    echo 'alias grep="rg"' >> "/home/$SSH_USER/.bashrc"
    echo 'alias top="btop"' >> "/home/$SSH_USER/.bashrc"
    
    # Create a symbolic link from user home to /app for convenience
    sudo -u "$SSH_USER" ln -sf /app "/home/$SSH_USER/app"
    
    # Set proper ownership
    chown -R "$SSH_USER:$SSH_USER" "/home/$SSH_USER"
    
    # Give user write permissions to /app directory
    chown -R "$SSH_USER:$SSH_USER" /app
    chmod -R 755 /app
    
    # Add user to root group for additional permissions
    usermod -aG root "$SSH_USER"
    
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