# zsh login config — macOS default shell.
# Shared aliases/env/functions live in common.sh (bash + zsh).

# Completion
autoload -Uz compinit && compinit

# Shared aliases, env vars, and functions
[ -f "$HOME/.config/shell/common.sh" ] && . "$HOME/.config/shell/common.sh"

# Rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# fnm (Node version manager)
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  export PATH="$FNM_PATH/aliases/default/bin:$PATH"
  eval "$(fnm env --use-on-cd --shell zsh)"
fi

# fzf keybindings (Ctrl+T: files / Ctrl+R: history / Alt+C: cd)
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh)"
fi

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

# Machine-local overrides (PATH additions, work credentials, etc.)
[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"
