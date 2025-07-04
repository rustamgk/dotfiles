# Multi-platform development environment
# Supports macOS, Linux, and Windows WSL2
FROM ubuntu:22.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV TERM=xterm-256color
ENV SHELL=/bin/zsh
ENV USER=rustamgk
ENV HOME=/home/${USER}
ENV WORKSPACE_DIR=${HOME}/workspace
ENV HELM_DIR=${HOME}/helm

# Create user and directories
RUN useradd -m -s /bin/zsh ${USER} && \
    mkdir -p ${WORKSPACE_DIR} ${HELM_DIR} && \
    chown -R ${USER}:${USER} ${HOME}

# Install base packages
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    wget \
    git \
    vim \
    nano \
    unzip \
    tar \
    gzip \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    file \
    procps \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install Homebrew (Linux version)
RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /etc/profile

# Switch to user
USER ${USER}
WORKDIR ${HOME}

# Install development tools via Homebrew (latest versions)
RUN /home/linuxbrew/.linuxbrew/bin/brew install \
    zsh \
    tmux \
    git \
    neovim \
    fzf \
    starship \
    autojump \
    zoxide \
    tldr \
    ansible \
    mc \
    flux \
    k9s \
    kubectl \
    helm \
    go \
    python3 \
    node \
    tree \
    htop \
    btop \
    jq \
    yq \
    bat \
    eza \
    ripgrep \
    fd \
    gh \
    lazygit \
    kubectx \
    terraform \
    stern \
    yamllint \
    pyenv \
    && /home/linuxbrew/.linuxbrew/bin/brew cleanup

# Install additional tools via Homebrew tap
RUN /home/linuxbrew/.linuxbrew/bin/brew tap argoproj/tap && \
    /home/linuxbrew/.linuxbrew/bin/brew install argoproj/tap/argocd && \
    /home/linuxbrew/.linuxbrew/bin/brew install nats-io/nats-tools/nats && \
    /home/linuxbrew/.linuxbrew/bin/brew cleanup

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install tmux plugin manager
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Copy configuration files
COPY --chown=${USER}:${USER} configs/.zshrc ${HOME}/.zshrc
COPY --chown=${USER}:${USER} configs/.tmux.conf ${HOME}/.tmux.conf
COPY --chown=${USER}:${USER} configs/starship.toml ${HOME}/.config/starship.toml
COPY --chown=${USER}:${USER} configs/.gitconfig ${HOME}/.gitconfig

# Set up zsh as default shell
RUN sudo chsh -s $(which zsh) ${USER}

# Initialize starship and other tools
RUN mkdir -p ${HOME}/.config

# Set up workspace mount points with platform detection
RUN mkdir -p ${WORKSPACE_DIR} ${HELM_DIR}

# Platform-specific setup script
COPY --chown=${USER}:${USER} scripts/setup-mounts.sh ${HOME}/setup-mounts.sh
RUN chmod +x ${HOME}/setup-mounts.sh

# Install tmux plugins
RUN ${HOME}/.tmux/plugins/tpm/scripts/install_plugins.sh

# Set up SSH directory
RUN mkdir -p ${HOME}/.ssh && chmod 700 ${HOME}/.ssh

# Create entrypoint script
COPY --chown=${USER}:${USER} scripts/entrypoint.sh ${HOME}/entrypoint.sh
RUN chmod +x ${HOME}/entrypoint.sh

# Expose common ports for development
EXPOSE 3000 8080 8000 9000

# Set entrypoint
ENTRYPOINT ["/home/rustamgk/entrypoint.sh"]

# Default command
CMD ["zsh"]
