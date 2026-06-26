#!/usr/bin/env bash
set -euo pipefail

BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
DRY_RUN="${DRY_RUN:-0}"

log() { echo "[backup] $*"; }

backup_file() {
  local src="$1"
  local dest="$BACKUP_DIR/${src#$HOME/}"
  if [ -e "$src" ] && [ ! -L "$src" ]; then
    if [ "$DRY_RUN" = "1" ]; then
      log "[dry-run] would back up: $src → $dest"
    else
      mkdir -p "$(dirname "$dest")"
      mv "$src" "$dest"
      log "backed up: $src → $dest"
    fi
  fi
}

FILES_TO_BACKUP=(
  "$HOME/.bashrc"
  "$HOME/.zshrc"
  "$HOME/.gitconfig"
  "$HOME/.gitignore_global"
  "$HOME/.config/starship.toml"
  "$HOME/.config/lazygit/config.yml"
  "$HOME/.config/bat/themes/tokyonight_storm.tmTheme"
  "$HOME/.markdownlint-cli2.yaml"
)

if [ "$DRY_RUN" = "1" ]; then
  log "dry-run mode — nothing will be moved"
fi

for f in "${FILES_TO_BACKUP[@]}"; do
  backup_file "$f"
done

# Back up nvim config directory (non-symlink)
if [ -d "$HOME/.config/nvim" ] && [ ! -L "$HOME/.config/nvim" ]; then
  if [ "$DRY_RUN" = "1" ]; then
    log "[dry-run] would back up: $HOME/.config/nvim → $BACKUP_DIR/.config/nvim"
  else
    mkdir -p "$BACKUP_DIR/.config"
    mv "$HOME/.config/nvim" "$BACKUP_DIR/.config/nvim"
    log "backed up: $HOME/.config/nvim → $BACKUP_DIR/.config/nvim"
  fi
fi

# Back up shell config directory (non-symlink)
if [ -d "$HOME/.config/shell" ] && [ ! -L "$HOME/.config/shell" ]; then
  if [ "$DRY_RUN" = "1" ]; then
    log "[dry-run] would back up: $HOME/.config/shell → $BACKUP_DIR/.config/shell"
  else
    mkdir -p "$BACKUP_DIR/.config"
    mv "$HOME/.config/shell" "$BACKUP_DIR/.config/shell"
    log "backed up: $HOME/.config/shell → $BACKUP_DIR/.config/shell"
  fi
fi

if [ "$DRY_RUN" != "1" ] && [ -d "$BACKUP_DIR" ]; then
  log "backup saved to: $BACKUP_DIR"
fi
