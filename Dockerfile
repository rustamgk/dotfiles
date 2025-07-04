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

# Install base packages and sudo for Homebrew
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
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Add user to sudoers for Homebrew installation
RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to user before installing Homebrew
USER ${USER}
WORKDIR ${HOME}

# Install Homebrew (Linux version) as user with sudo access
RUN NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Add Homebrew to PATH
ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
RUN echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc \
    && echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.zshrc

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
    dive \
    hadolint \
    trivy \
    grype \
    && /home/linuxbrew/.linuxbrew/bin/brew cleanup

# Install additional tools via Homebrew taps and packages
RUN /home/linuxbrew/.linuxbrew/bin/brew tap argoproj/tap && \
    /home/linuxbrew/.linuxbrew/bin/brew tap azure/functions && \
    /home/linuxbrew/.linuxbrew/bin/brew install \
    argoproj/tap/argocd \
    nats-io/nats-tools/nats \
    azure-cli \
    kubeaudit \
    kube-bench \
    kustomize \
    terragrunt \
    tflint \
    grpcurl \
    krew \
    checkov \
    && /home/linuxbrew/.linuxbrew/bin/brew cleanup

# Configure Azure CLI
RUN az config set extension.use_dynamic_install=yes_without_prompt && \
    az extension add --name azure-devops

# Install Python security tools that aren't available via Homebrew
RUN python3 -m pip install --break-system-packages kube-hunter

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install Oh My Zsh plugins (using ZSH_CUSTOM directory)
RUN git clone https://github.com/zsh-users/zsh-autosuggestions.git /home/rustamgk/.oh-my-zsh/custom/plugins/zsh-autosuggestions && \
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /home/rustamgk/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Install LazyVim (modern Neovim configuration)
RUN git clone https://github.com/LazyVim/starter /home/rustamgk/.config/nvim && \
    rm -rf /home/rustamgk/.config/nvim/.git

# Install tmux plugin manager
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Copy configuration files
COPY --chown=${USER}:${USER} configs/.zshrc ${HOME}/.zshrc
COPY --chown=${USER}:${USER} configs/.tmux.conf ${HOME}/.tmux.conf
COPY --chown=${USER}:${USER} configs/.tmux.base.conf ${HOME}/.tmux.base.conf
COPY --chown=${USER}:${USER} configs/starship.toml ${HOME}/.config/starship.toml
COPY --chown=${USER}:${USER} configs/.gitconfig ${HOME}/.gitconfig
COPY --chown=${USER}:${USER} configs/nvim/ ${HOME}/.config/nvim/

# Fix line endings for all configuration files
RUN sed -i 's/\r$//' ${HOME}/.zshrc ${HOME}/.tmux.conf ${HOME}/.tmux.base.conf ${HOME}/.gitconfig

# Set up zsh as default shell
RUN sudo chsh -s $(which zsh) ${USER}

# Initialize starship and other tools
RUN mkdir -p /home/rustamgk/.config

# Set up workspace mount points with platform detection
RUN mkdir -p ${WORKSPACE_DIR} ${HELM_DIR}

# Platform-specific setup script
COPY --chown=${USER}:${USER} scripts/setup-mounts.sh ${HOME}/setup-mounts.sh
RUN sed -i 's/\r$//' /home/rustamgk/setup-mounts.sh && chmod +x /home/rustamgk/setup-mounts.sh

# Set up SSH directory
RUN mkdir -p /home/rustamgk/.ssh && chmod 700 /home/rustamgk/.ssh

# Create entrypoint script
COPY --chown=${USER}:${USER} scripts/entrypoint.sh /home/rustamgk/entrypoint.sh
RUN sed -i 's/\r$//' /home/rustamgk/entrypoint.sh && chmod +x /home/rustamgk/entrypoint.sh

# Expose common ports for development
EXPOSE 3000 8080 8000 9000

# Set entrypoint
ENTRYPOINT ["/home/rustamgk/entrypoint.sh"]

# Default command
CMD ["zsh"]
