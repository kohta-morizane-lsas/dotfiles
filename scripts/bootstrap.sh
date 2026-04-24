#!/usr/bin/env bash
set -euo pipefail

log() { echo "[bootstrap] $*"; }

OS="$(uname -s)"

install_linux() {
  log "Detected Linux (Ubuntu/Debian)"
  sudo apt-get update -qq

  # stow is required for install.sh
  sudo apt-get install -y stow

  # Core tools
  sudo apt-get install -y \
    git curl wget unzip \
    ripgrep fd-find fzf \
    bat eza zoxide \
    neovim lazygit

  # batcat -> bat symlink (Ubuntu names it batcat)
  if command -v batcat >/dev/null && ! command -v bat >/dev/null; then
    mkdir -p "$HOME/.local/bin"
    ln -sf "$(command -v batcat)" "$HOME/.local/bin/bat"
    log "Created ~/.local/bin/bat -> batcat"
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
  fi

  brew install \
    stow git \
    ripgrep fd fzf \
    bat eza zoxide \
    neovim lazygit starship
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
