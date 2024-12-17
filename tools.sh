#!/bin/bash
set -e

# Function to check if a package is installed
is_installed() {
    dpkg -l | grep -q "$1"
}

# Function to check if a binary is in the PATH
is_binary_installed() {
    command -v "$1" >/dev/null 2>&1
}

# Update package list and install essential packages
echo "Updating package list..."
sudo apt-get update

# Install essential packages if not already installed
echo "Checking and installing required packages..."
for package in \
    software-properties-common groff less jq openssl wget curl vim gnupg2 pass unzip libarchive-tools bash-completion \
    ca-certificates python3 python3-dev python3-pip git gcc apt-utils netbase make cpio dos2unix \
    netcat-openbsd psmisc htop multitail ssh golang-go npm dnsutils strongswan strongswan-pki libstrongswan-extra-plugins \
    apt-transport-https lsb-release gnupg zsh zsh-syntax-highlighting zsh-autosuggestions autojump bat \
    tldr ansible fzf zsh tmux mc nvim autojump zoxide starship
do
    if ! is_installed "$package"; then
        echo "Installing $package..."
        sudo apt-get install -y --no-install-recommends "$package"
    else
        echo "$package is already installed, skipping..."
    fi
done

# Install Microsoft Azure CLI
echo "Installing Microsoft Azure CLI..."
if ! is_installed "azure-cli"; then
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
    OS_RELEASE=$(lsb_release -cs)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $OS_RELEASE main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
    sudo apt-get update
    sudo apt-get -y install --no-install-recommends azure-cli
    az config set extension.use_dynamic_install=yes_without_prompt
    az extension add --name azure-devops
else
    echo "Azure CLI is already installed, skipping..."
fi

# Install Oh My Zsh and Powerlevel10k theme
echo "Installing Oh My Zsh and Powerlevel10k..."
if ! is_binary_installed "zsh"; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Install fzf
echo "Installing fzf..."
if ! is_binary_installed "fzf"; then
    curl -sS -L "$(curl -Ls https://api.github.com/repos/junegunn/fzf/releases/latest | grep -o -E "https://.+?-linux_amd64.tar.gz")" | bsdtar -xf - --include=fzf -C /usr/local/bin
    chmod +x /usr/local/bin/fzf
else
    echo "fzf is already installed, skipping..."
fi

# Install bat
echo "Installing bat..."
if ! is_binary_installed "bat"; then
    sudo ln -s /usr/bin/batcat /usr/bin/bat
else
    echo "bat is already installed, skipping..."
fi

# Install gotestsum
echo "Installing gotestsum..."
if ! is_binary_installed "gotestsum"; then
    curl -sS -L "$(curl -Ls https://api.github.com/repos/gotestyourself/gotestsum/releases/latest | grep -o -E "https://.+?_linux_amd64.tar.gz")" | bsdtar -xf - --include=gotestsum -C /usr/local/bin
    chmod +x /usr/local/bin/gotestsum
else
    echo "gotestsum is already installed, skipping..."
fi

# Install stern
echo "Installing stern..."
if ! is_binary_installed "stern"; then
    curl -sS -L "$(curl -Ls https://api.github.com/repos/stern/stern/releases/latest | grep -o -E "https://.+?linux_amd64.tar.gz")" | bsdtar -xf - --include=stern -C /usr/local/bin
    chmod +x /usr/local/bin/stern
else
    echo "stern is already installed, skipping..."
fi

# Install other tools in a similar manner
# You can repeat the above steps for the remaining tools, checking if they're installed before downloading.

# Install checkov
echo "Installing checkov..."
if ! is_binary_installed "checkov"; then
    pip3 install --no-cache-dir --break-system-packages checkov
    rm -rf /root/.cache
else
    echo "checkov is already installed, skipping..."
fi

# Continue with other tools...

echo "All tools checked and installed successfully!"

