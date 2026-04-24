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
  "$HOME/.gitconfig"
  "$HOME/.gitignore_global"
  "$HOME/.config/starship.toml"
  "$HOME/.config/lazygit/config.yml"
  "$HOME/.claude/CLAUDE.md"
)

if [ "$DRY_RUN" = "1" ]; then
  log "dry-run mode — nothing will be moved"
fi

for f in "${FILES_TO_BACKUP[@]}"; do
  backup_file "$f"
done

# Back up claude/rules directory (non-symlink)
if [ -d "$HOME/.claude/rules" ] && [ ! -L "$HOME/.claude/rules" ]; then
  if [ "$DRY_RUN" = "1" ]; then
    log "[dry-run] would back up: $HOME/.claude/rules → $BACKUP_DIR/.claude/rules"
  else
    mkdir -p "$BACKUP_DIR/.claude"
    mv "$HOME/.claude/rules" "$BACKUP_DIR/.claude/rules"
    log "backed up: $HOME/.claude/rules → $BACKUP_DIR/.claude/rules"
  fi
fi

if [ "$DRY_RUN" != "1" ] && [ -d "$BACKUP_DIR" ]; then
  log "backup saved to: $BACKUP_DIR"
fi
