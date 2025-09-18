FROM ubuntu:24.04

# Install system dependencies, Python 3.11, and development tools in one layer
RUN apt-get update && apt-get install -y \
    # Essential build tools
    curl \
    build-essential \
    pkg-config \
    libssl-dev \
    ca-certificates \
    gnupg \
    gnupg2 \
    lsb-release \
    wget \
    unzip \
    zip \
    zstd \
    # Python and pip
    python3.12 \
    python3.12-dev \
    python3.12-venv \
    python3-pip \
    # Development tools
    git \
    vim \
    net-tools \
    jq \
    lftp \
    moreutils \
    # Additional utilities from spec
    xdg-utils \
    pulseaudio \
    ffmpeg \
    p7zip-full \
    poppler-utils \
    fd-find \
    zoxide \
    imagemagick \
    exiftool \
    # SSH server and sudo
    openssh-server \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    # Create symlinks for python and python3 to point to python3.12
    && ln -sf /usr/bin/python3.12 /usr/bin/python3 \
    && ln -sf /usr/bin/python3.12 /usr/bin/python



# Install special tools from GitHub releases in one optimized layer
RUN ARCH=$(dpkg --print-architecture) && echo "Architecture: $ARCH" && \
    # Get all versions at once
    RIPGREP_VERSION=$(curl -s https://api.github.com/repos/BurntSushi/ripgrep/releases/latest | jq -r .tag_name) && \
    BAT_VERSION=$(curl -s https://api.github.com/repos/sharkdp/bat/releases/latest | jq -r .tag_name) && \
    BTOP_VERSION=$(curl -s https://api.github.com/repos/aristocratos/btop/releases/latest | jq -r .tag_name) && \
    YQ_VERSION=$(curl -s https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r .tag_name) && \
    # Install ripgrep
    if [ "$ARCH" = "arm64" ]; then \
    wget -O /tmp/ripgrep.tar.gz "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep-${RIPGREP_VERSION#v}-aarch64-unknown-linux-gnu.tar.gz" && \
    tar -xzf /tmp/ripgrep.tar.gz -C /tmp && \
    cp /tmp/ripgrep-${RIPGREP_VERSION#v}-aarch64-unknown-linux-gnu/rg /usr/local/bin/ && \
    chmod +x /usr/local/bin/rg && \
    rm -rf /tmp/ripgrep.tar.gz /tmp/ripgrep-${RIPGREP_VERSION#v}-aarch64-unknown-linux-gnu; \
    else \
    wget -O /tmp/ripgrep.deb "https://github.com/BurntSushi/ripgrep/releases/download/${RIPGREP_VERSION}/ripgrep_${RIPGREP_VERSION#v}-1_amd64.deb" && \
    dpkg -i /tmp/ripgrep.deb && \
    rm /tmp/ripgrep.deb; \
    fi && \
    # Install bat
    if [ "$ARCH" = "arm64" ]; then \
    wget -O /tmp/bat.deb "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat_${BAT_VERSION#v}_arm64.deb"; \
    else \
    wget -O /tmp/bat.deb "https://github.com/sharkdp/bat/releases/download/${BAT_VERSION}/bat_${BAT_VERSION#v}_amd64.deb"; \
    fi && \
    dpkg -i /tmp/bat.deb && \
    rm /tmp/bat.deb && \
    # Install btop
    if [ "$ARCH" = "arm64" ]; then \
    wget -O /tmp/btop.tbz "https://github.com/aristocratos/btop/releases/download/${BTOP_VERSION}/btop-aarch64-linux-musl.tbz"; \
    else \
    wget -O /tmp/btop.tbz "https://github.com/aristocratos/btop/releases/download/${BTOP_VERSION}/btop-x86_64-linux-musl.tbz"; \
    fi && \
    tar -xjf /tmp/btop.tbz -C /tmp && \
    cp /tmp/btop/bin/btop /usr/local/bin/ && \
    chmod +x /usr/local/bin/btop && \
    rm -rf /tmp/btop.tbz /tmp/btop && \
    # Install yq
    if [ "$ARCH" = "arm64" ]; then \
    wget -O /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_arm64"; \
    else \
    wget -O /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64"; \
    fi && \
    chmod +x /usr/local/bin/yq && \
    # Install DotSlash
    if [ "$ARCH" = "arm64" ]; then \
    curl -LSfs "https://github.com/facebook/dotslash/releases/latest/download/dotslash-ubuntu-24.04.aarch64.tar.gz" | tar fxz - -C /usr/local/bin; \
    else \
    curl -LSfs "https://github.com/facebook/dotslash/releases/latest/download/dotslash-ubuntu-24.04.x86_64.tar.gz" | tar fxz - -C /usr/local/bin; \
    fi

# Copy and run tool verification script
COPY config/scripts/verify-tools.sh /tmp/verify-tools.sh
RUN chmod +x /tmp/verify-tools.sh && \
    /tmp/verify-tools.sh && \
    rm /tmp/verify-tools.sh

# Copy essential utility scripts
COPY config/scripts/env-check.sh /usr/local/bin/env-check
COPY config/scripts/fallback-shell.sh /usr/local/bin/fallback-shell
COPY config/scripts/test-terminal-output.sh /usr/local/bin/test-terminal
COPY config/scripts/ssh-setup.sh /usr/local/bin/ssh-setup
COPY config/scripts/test-ssh.sh /usr/local/bin/test-ssh
COPY config/scripts/setup-user-env.sh /usr/local/bin/setup-user-env
COPY config/scripts/setup-git-config.sh /usr/local/bin/setup-git-config
COPY config/scripts/test-git-config.sh /usr/local/bin/test-git-config
RUN chmod +x /usr/local/bin/env-check /usr/local/bin/fallback-shell /usr/local/bin/test-terminal /usr/local/bin/ssh-setup /usr/local/bin/test-ssh /usr/local/bin/setup-user-env /usr/local/bin/setup-git-config /usr/local/bin/test-git-config

# Set bash as default shell
ENV SHELL=/bin/bash

# Set timezone to Asia/Taipei (+0800)
ENV TZ=Asia/Taipei
RUN ln -sf /usr/share/zoneinfo/Asia/Taipei /etc/localtime && \
    echo "Asia/Taipei" > /etc/timezone

# Set basic environment variables
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
ENV TERM=xterm-256color
ENV PATH="/opt/rust/bin:/usr/local/bin:$PATH"
ENV STARSHIP_CONFIG="/etc/starship/starship.toml"

# Install Rust system-wide with retry mechanism
RUN ARCH=$(dpkg --print-architecture) && \
    RUSTUP_HOME=/opt/rust CARGO_HOME=/opt/rust && \
    export RUSTUP_HOME CARGO_HOME && \
    mkdir -p /opt/rust && \
    # Download rustup with retry
    for i in {1..3}; do \
        if [ "$ARCH" = "arm64" ]; then \
            wget -O /tmp/rustup-init https://static.rust-lang.org/rustup/dist/aarch64-unknown-linux-gnu/rustup-init && break || sleep 5; \
        else \
            wget -O /tmp/rustup-init https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init && break || sleep 5; \
        fi; \
    done && \
    chmod +x /tmp/rustup-init && \
    /tmp/rustup-init -y --no-modify-path --default-toolchain stable && \
    rm /tmp/rustup-init && \
    # Add Rust to system PATH
    echo 'export PATH="/opt/rust/bin:$PATH"' >> /etc/bash.bashrc && \
    export PATH="/opt/rust/bin:$PATH"

# Install UV (Python package manager) with retry
RUN for i in {1..3}; do \
        curl -LsSf https://astral.sh/uv/install.sh | UV_INSTALL_DIR=/usr/local/bin sh && break || sleep 5; \
    done

# Install Yazi file manager using pre-built binaries instead of compiling
RUN ARCH=$(dpkg --print-architecture) && \
    YAZI_VERSION=$(curl -s "https://api.github.com/repos/sxyazi/yazi/releases/latest" | jq -r .tag_name) && \
    if [ "$ARCH" = "arm64" ]; then \
        wget -O /tmp/yazi.zip "https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-aarch64-unknown-linux-musl.zip" && \
        unzip /tmp/yazi.zip -d /tmp && \
        cp /tmp/yazi-aarch64-unknown-linux-musl/yazi /usr/local/bin/ && \
        cp /tmp/yazi-aarch64-unknown-linux-musl/ya /usr/local/bin/ && \
        rm -rf /tmp/yazi.zip /tmp/yazi-aarch64-unknown-linux-musl; \
    else \
        wget -O /tmp/yazi.zip "https://github.com/sxyazi/yazi/releases/download/${YAZI_VERSION}/yazi-x86_64-unknown-linux-musl.zip" && \
        unzip /tmp/yazi.zip -d /tmp && \
        cp /tmp/yazi-x86_64-unknown-linux-musl/yazi /usr/local/bin/ && \
        cp /tmp/yazi-x86_64-unknown-linux-musl/ya /usr/local/bin/ && \
        rm -rf /tmp/yazi.zip /tmp/yazi-x86_64-unknown-linux-musl; \
    fi && \
    chmod +x /usr/local/bin/yazi /usr/local/bin/ya && \
    # Create system-wide Yazi config directory
    mkdir -p /etc/yazi && \
    echo -e '[flavor]\ndark = "catppuccin-frappe"' > /etc/yazi/theme.toml

# Setup system-wide directories, shell functions, and symbolic links
RUN mkdir -p /usr/local/bin && \
    # Create bat symbolic link system-wide (using existing batcat from apt)
    ln -sf /usr/bin/batcat /usr/local/bin/bat && \
    # Add Yazi y function to system-wide bashrc
    cat <<'EOF' >> /etc/bash.bashrc

# Yazi function for directory navigation
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
EOF

# Install Node.js system-wide using NodeSource repository (much faster)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    # Create symlinks for system-wide access
    mkdir -p /opt/node && \
    ln -sf /usr/bin/node /opt/node/node && \
    ln -sf /usr/bin/npm /opt/node/npm && \
    ln -sf /usr/bin/npx /opt/node/npx && \
    # Add Node.js to system PATH
    echo 'export PATH="/usr/bin:$PATH"' >> /etc/bash.bashrc

# Setup Bash environment variables and settings
RUN cat <<'EOF' >> /root/.profile


# 針對暗色背景終端機的明亮色彩配置
export JQ_COLORS="33:93:93:96:92:97:1;97:4;97"

export EDITOR=vim
export GPG_TTY=$(tty)
EOF

RUN cat <<'EOF' >> /root/.bashrc

# Enable programmable completion features
shopt -u direxpand
shopt -s no_empty_cmd_completion
EOF

# Setup SSH keys and create projects directory
RUN ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -P "" && \
    touch /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys && \
    # Create projects directory and make it accessible to all users
    mkdir -p /opt/projects && \
    chmod 755 /opt/projects && \
    # Create root projects directory and link to system projects
    mkdir -p /root/projects && \
    ln -sf /opt/projects /root/system-projects

# Install Starship prompt system-wide
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y && \
    # Create system-wide config directory and install Catppuccin Powerline preset
    mkdir -p /etc/starship && \
    /usr/local/bin/starship preset catppuccin-powerline -o /etc/starship/starship.toml && \
    # Enable line break in the config
    sed -i '/^\[line_break\]/,/^\[/ s/disabled = true/disabled = false/' /etc/starship/starship.toml && \
    # Add starship to system-wide bashrc
    echo 'export STARSHIP_CONFIG="/etc/starship/starship.toml"' >> /etc/bash.bashrc && \
    echo 'eval "$(starship init bash)"' >> /etc/bash.bashrc && \
    # Also create config for root
    mkdir -p /root/.config && \
    cp /etc/starship/starship.toml /root/.config/starship.toml && \
    echo 'eval "$(starship init bash)"' >> /root/.bashrc

# Install fzf fuzzy finder system-wide
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /opt/fzf && \
    /opt/fzf/install --all --no-update-rc && \
    # Add fzf to system PATH and bashrc
    ln -sf /opt/fzf/bin/fzf /usr/local/bin/fzf && \
    echo 'source /opt/fzf/shell/completion.bash' >> /etc/bash.bashrc && \
    echo 'source /opt/fzf/shell/key-bindings.bash' >> /etc/bash.bashrc && \
    # Also install for root user
    git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf && \
    /root/.fzf/install --all

# Setup Vim editor configuration
RUN cat <<'EOF' > /root/.vimrc
syntax on
set background=dark

let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"

inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
  set pastetoggle=<Esc>[201~
  set paste
  return ""
endfunction
EOF

# Install GitHub CLI
RUN type -p wget >/dev/null || (apt-get update && apt-get install wget -y) && \
    mkdir -p -m 755 /etc/apt/keyrings && \
    wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt-get update && \
    apt-get install gh -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install AIChat LLM CLI tool
RUN ARCH=$(dpkg --print-architecture) && \
    AICHAT_VERSION=$(curl -s "https://api.github.com/repos/sigoden/aichat/releases/latest" | jq -r .tag_name) && \
    if [ "$ARCH" = "arm64" ]; then \
        curl -sL "https://github.com/sigoden/aichat/releases/download/${AICHAT_VERSION}/aichat-${AICHAT_VERSION}-aarch64-unknown-linux-musl.tar.gz" | \
        tar -xzO aichat > /usr/local/bin/aichat; \
    else \
        curl -sL "https://github.com/sigoden/aichat/releases/download/${AICHAT_VERSION}/aichat-${AICHAT_VERSION}-x86_64-unknown-linux-musl.tar.gz" | \
        tar -xzO aichat > /usr/local/bin/aichat; \
    fi && \
    chmod +x /usr/local/bin/aichat

# Install Claude Code using npm system-wide
RUN npm install -g @anthropic-ai/claude-code

# Configure Claude Code with MCP context7 and create cc alias
RUN claude mcp add -s user context7 -- npx -y @upstash/context7-mcp@latest && \
    # Create cc alias for claude with skip permissions flag
    echo 'alias cc="claude --dangerously-skip-permissions"' >> /etc/bash.bashrc && \
    echo 'alias cc="claude --dangerously-skip-permissions"' >> /root/.bashrc

# Create system-wide environment file
RUN cat <<EOF > /etc/environment
PATH="/opt/rust/bin:/usr/bin:/usr/local/bin:/bin"
STARSHIP_CONFIG="/etc/starship/starship.toml"
LANG="C.UTF-8"
LC_ALL="C.UTF-8"
TERM="xterm-256color"
EOF

# Setup enhanced shell aliases for better command experience system-wide
RUN cat <<'EOF' >> /etc/bash.bashrc

# Enhanced command aliases (smart fallbacks to original commands if needed)
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
EOF

# Also add aliases to root user bashrc
RUN cat <<'EOF' >> /root/.bashrc

# Enhanced command aliases (smart fallbacks to original commands if needed)
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
EOF

# Create SSH directory and configure sudo
RUN mkdir -p /var/run/sshd && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Expose SSH port
EXPOSE 22

WORKDIR /app

# Ensure /app directory has proper permissions
RUN chmod 755 /app

# Create startup script
RUN echo '#!/bin/bash\nssh-setup\nsetup-git-config\nexec "$@"' > /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]