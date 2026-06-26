#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="$HOME"
ALL_PACKAGES=(bash zsh shell git starship lazygit nvim bat)

usage() {
  echo "Usage: $0 [--all | <pkg> ...] [--unstow] [--dry-run]"
  echo ""
  echo "Packages: ${ALL_PACKAGES[*]}"
  echo ""
  echo "  --all       Install all packages"
  echo "  --unstow    Remove symlinks instead of creating them"
  echo "  --dry-run   Show what would happen without making changes"
  exit 1
}

PACKAGES=()
UNSTOW=0
DRY_RUN=0

for arg in "$@"; do
  case "$arg" in
    --all)     PACKAGES=("${ALL_PACKAGES[@]}") ;;
    --unstow)  UNSTOW=1 ;;
    --dry-run) DRY_RUN=1 ;;
    --help|-h) usage ;;
    *)
      if [[ " ${ALL_PACKAGES[*]} " == *" $arg "* ]]; then
        PACKAGES+=("$arg")
      else
        echo "Unknown package or flag: $arg" >&2
        usage
      fi
      ;;
  esac
done

[ ${#PACKAGES[@]} -eq 0 ] && usage

if ! command -v stow >/dev/null 2>&1; then
  echo "Error: stow is not installed. Run scripts/bootstrap.sh first." >&2
  exit 1
fi

if [ "$UNSTOW" -eq 0 ] && [ "$DRY_RUN" -eq 0 ]; then
  echo "Backing up existing dotfiles..."
  bash "$DOTFILES_DIR/scripts/backup-existing.sh"
fi

STOW_FLAGS="-v -R -t $TARGET"
[ "$DRY_RUN" -eq 1 ] && STOW_FLAGS="$STOW_FLAGS -n"
[ "$UNSTOW" -eq 1 ] && STOW_FLAGS="-v -D -t $TARGET"

for pkg in "${PACKAGES[@]}"; do
  echo "→ stow $pkg"
  stow $STOW_FLAGS -d "$DOTFILES_DIR" "$pkg"
done

# Set up ~/.gitconfig.local from example if missing
if [ "$UNSTOW" -eq 0 ] && [ "$DRY_RUN" -eq 0 ] && [ ! -f "$TARGET/.gitconfig.local" ]; then
  cp "$DOTFILES_DIR/git/.gitconfig.local.example" "$TARGET/.gitconfig.local"
  echo ""
  echo "Created ~/.gitconfig.local from example — fill in your name and email:"
  echo "  git config -f ~/.gitconfig.local user.name  'Your Name'"
  echo "  git config -f ~/.gitconfig.local user.email 'you@example.com'"
fi

# Rebuild bat's theme cache so the stowed theme is picked up
if [ "$UNSTOW" -eq 0 ] && [ "$DRY_RUN" -eq 0 ] && [ -d "$TARGET/.config/bat/themes" ]; then
  if command -v bat >/dev/null 2>&1; then
    bat cache --build >/dev/null
    echo "Rebuilt bat theme cache."
  elif command -v batcat >/dev/null 2>&1; then
    batcat cache --build >/dev/null
    echo "Rebuilt bat theme cache."
  fi
fi

echo ""
echo "Done."
