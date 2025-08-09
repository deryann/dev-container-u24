FROM ubuntu:22.04

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
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
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
    # Create symlinks for python and python3 to point to python3.11
    && ln -sf /usr/bin/python3.11 /usr/bin/python3 \
    && ln -sf /usr/bin/python3.11 /usr/bin/python



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
    curl -LSfs "https://github.com/facebook/dotslash/releases/latest/download/dotslash-ubuntu-22.04.aarch64.tar.gz" | tar fxz - -C /usr/local/bin; \
    else \
    curl -LSfs "https://github.com/facebook/dotslash/releases/latest/download/dotslash-ubuntu-22.04.x86_64.tar.gz" | tar fxz - -C /usr/local/bin; \
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
RUN chmod +x /usr/local/bin/env-check /usr/local/bin/fallback-shell /usr/local/bin/test-terminal /usr/local/bin/ssh-setup /usr/local/bin/test-ssh

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
ENV PATH="/root/.cargo/bin:$PATH"

# Install Rust, UV, and Yazi in one layer
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && \
    curl -LsSf https://astral.sh/uv/install.sh | sh && \
    echo 'export PATH="$HOME/.cargo/bin:$PATH"' >> /root/.bashrc && \
    # Install Yazi file manager
    /root/.cargo/bin/cargo install --locked yazi-fm yazi-cli && \
    # Install Catppuccin Frappe flavor for Yazi
    mkdir -p /root/.config/yazi && \
    /root/.cargo/bin/ya pkg add yazi-rs/flavors:catppuccin-frappe && \
    echo -e '[flavor]\ndark = "catppuccin-frappe"' > /root/.config/yazi/theme.toml

# Setup user directories, shell functions, and symbolic links
RUN mkdir -p /root/.local/bin && \
    # Create bat symbolic link (using existing batcat from apt)
    ln -sf /usr/bin/batcat /root/.local/bin/bat && \
    # Add ~/.local/bin to PATH
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> /root/.bashrc && \
    # Add Yazi y function to bashrc
    cat <<'EOF' >> /root/.bashrc

# Yazi function for directory navigation
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}
EOF

# Install Node.js using nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/$(curl -s "https://api.github.com/repos/nvm-sh/nvm/releases/latest" | jq -r .tag_name)/install.sh | bash && \
    # Source nvm and install Node.js 22
    bash -c 'source /root/.nvm/nvm.sh && nvm install 22 && nvm use 22 && nvm alias default 22' && \
    # Add nvm to bashrc
    echo 'export NVM_DIR="$HOME/.nvm"' >> /root/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> /root/.bashrc && \
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> /root/.bashrc

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
    # Create projects directory
    mkdir -p /root/projects

# Install Starship prompt
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y && \
    # Create config directory and install Catppuccin Powerline preset
    mkdir -p /root/.config && \
    /usr/local/bin/starship preset catppuccin-powerline -o /root/.config/starship.toml && \
    # Enable line break in the config
    sed -i '/^\[line_break\]/,/^\[/ s/disabled = true/disabled = false/' /root/.config/starship.toml && \
    # Add starship to bashrc
    echo 'eval "$(starship init bash)"' >> /root/.bashrc

# Install fzf fuzzy finder
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /root/.fzf && \
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
RUN AICHAT_VERSION=$(curl -s "https://api.github.com/repos/sigoden/aichat/releases/latest" | jq -r .tag_name) && \
    curl -sL "https://github.com/sigoden/aichat/releases/download/${AICHAT_VERSION}/aichat-${AICHAT_VERSION}-x86_64-unknown-linux-musl.tar.gz" | \
    tar -xzO aichat > /usr/local/bin/aichat && \
    chmod +x /usr/local/bin/aichat

# Install Claude Code using npm (requires Node.js/nvm to be loaded)
RUN bash -c 'source /root/.nvm/nvm.sh && npm install -g @anthropic-ai/claude-code'

# Setup enhanced shell aliases for better command experience
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
RUN echo '#!/bin/bash\nssh-setup\nexec "$@"' > /usr/local/bin/docker-entrypoint.sh && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["bash"]