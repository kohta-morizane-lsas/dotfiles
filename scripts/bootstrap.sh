#!/usr/bin/env bash
set -euo pipefail

log() { echo "[bootstrap] $*"; }

OS="$(uname -s)"
ARCH="$(uname -m)"

install_linux() {
  log "Detected Linux (Ubuntu/Debian)"

  if [ "$ARCH" != "x86_64" ]; then
    log "WARNING: binary installs below assume x86_64 (detected: $ARCH)"
  fi

  sudo apt-get update -qq

  # stow is required for install.sh
  sudo apt-get install -y stow

  # Core tools available in Ubuntu repos
  # (eza/lazygit/neovim are NOT installed via apt — see below:
  #  lazygit is absent from Ubuntu repos, apt's neovim is too old for LazyVim,
  #  and apt's eza lags far behind upstream)
  sudo apt-get install -y \
    git curl wget unzip \
    ripgrep fd-find fzf \
    bat zoxide

  # batcat -> bat symlink (Ubuntu names it batcat)
  if command -v batcat >/dev/null && ! command -v bat >/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    log "Created ~/.local/bin/bat -> batcat"
  fi

  # eza — official deb repo (Ubuntu's universe version is outdated)
  if ! command -v eza >/dev/null; then
    log "Installing eza from deb.gierens.de..."
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc |
      sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" |
      sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null
    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
    sudo apt-get update -qq
    sudo apt-get install -y eza
  fi

  # lazygit — not in Ubuntu repos; install latest binary from GitHub releases
  if ! command -v lazygit >/dev/null; then
    log "Installing lazygit from GitHub releases..."
    local version
    version=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" |
      grep -Po '"tag_name": *"v\K[^"]*')
    curl -fsSL -o /tmp/lazygit.tar.gz \
      "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_x86_64.tar.gz"
    tar -xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    rm -f /tmp/lazygit.tar.gz /tmp/lazygit
    log "Installed lazygit v${version}"
  fi

  # neovim — apt's version (0.9.x on Ubuntu 24.04) is too old for LazyVim (needs 0.10+);
  # install the official tarball to /opt and symlink into /usr/local/bin
  if ! command -v nvim >/dev/null; then
    log "Installing neovim from GitHub releases..."
    curl -fsSL -o /tmp/nvim-linux-x86_64.tar.gz \
      "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz"
    sudo rm -rf /opt/nvim-linux-x86_64
    sudo tar -xf /tmp/nvim-linux-x86_64.tar.gz -C /opt
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim
    rm -f /tmp/nvim-linux-x86_64.tar.gz
    log "Installed neovim ($(/usr/local/bin/nvim --version | head -1))"
  fi

  # starship
  if ! command -v starship >/dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
  fi
}

install_macos() {
  log "Detected macOS"
  if ! command -v brew >/dev/null; then
    log "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Ensure brew is on PATH for the rest of this script (Apple Silicon default)
    [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
    [ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"
  fi

  local repo_root
  repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
  log "Installing CLI tools + fonts from Brewfile..."
  brew bundle --file="$repo_root/Brewfile"
}

case "$OS" in
  Linux)  install_linux ;;
  Darwin) install_macos ;;
  *)      echo "Unsupported OS: $OS" >&2; exit 1 ;;
esac

log ""
log "Bootstrap complete. Next steps:"
log "  1. Install fnm:   curl -fsSL https://fnm.vercel.app/install | bash"
log "  2. Install uv:    curl -LsSf https://astral.sh/uv/install.sh | sh"
log "  3. Install Rust:  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
log "  4. Run dotfiles:  ./install.sh --all"
