# Shared aliases, env vars, and functions (bash + zsh)
[ -f "$HOME/.config/shell/common.sh" ] && . "$HOME/.config/shell/common.sh"

# Rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# fnm (Node version manager)
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  export PATH="$FNM_PATH/aliases/default/bin:$PATH"
  eval "$(fnm env --use-on-cd --shell bash)"
fi

# fzf keybindings (Ctrl+T: files / Ctrl+R: history / Alt+C: cd)
# fzf >= 0.48 supports `fzf --bash`; apt's older fzf ships a key-bindings script
if fzf --bash >/dev/null 2>&1; then
  eval "$(fzf --bash)"
elif [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
  . /usr/share/doc/fzf/examples/key-bindings.bash
fi

eval "$(zoxide init bash)"
eval "$(starship init bash)"

# Machine-local overrides (PATH additions, WSL helpers, work credentials, etc.)
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
