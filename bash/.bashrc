export EDITOR=nvim
export VISUAL=nvim
export BAT_THEME="tokyonight_storm"

# fzf default search command
# Ubuntu uses fdfind; macOS/other uses fd — override in .bashrc.local if needed
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fdfind --type d --hidden --exclude .git'

alias ls='eza --group-directories-first --icons'
alias ll='eza -l --group-directories-first --icons --git'
alias la='eza -la --group-directories-first --icons --git'
alias lt='eza --tree --icons'
alias lrt='eza -l --group-directories-first --icons --git --sort newest'
alias cat='batcat'   # Ubuntu: batcat; macOS: bat — override in .bashrc.local
alias grep='rg'
alias ff='fdfind'    # Ubuntu: fdfind; macOS: fd — override in .bashrc.local
alias g='lazygit'
alias v='nvim'

# Rust
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# fnm (Node version manager)
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  export PATH="$FNM_PATH/aliases/default/bin:$PATH"
  eval "$(fnm env --use-on-cd --shell bash)"
fi

# fzf + fd: open file in nvim
# Usage: fo [-H|-r] [path] [pattern]
#   -H  search from $HOME; -r  search from /
fo() {
  local default_path="."
  case "${1:-}" in
    -H|--home) default_path="$HOME"; shift ;;
    -r|--root) default_path="/";     shift ;;
  esac
  local path="${1:-$default_path}"
  local pattern="${2:-}"
  local file
  file=$(fdfind --type f --hidden --exclude .git "$pattern" "$path" |
    fzf --preview 'batcat --style=numbers --color=always --line-range :100 {} 2>/dev/null || cat {}')
  [ -n "$file" ] && nvim "$file"
}

# fzf + fd: open file in $VISUAL (VSCode or other)
fc() {
  local path="${1:-.}"
  local pattern="${2:-}"
  local file
  file=$(fdfind --type f --hidden --exclude .git "$pattern" "$path" |
    fzf --preview 'batcat --style=numbers --color=always --line-range :100 {} 2>/dev/null || cat {}')
  [ -n "$file" ] && ${VISUAL:-nvim} "$file"
}

# fzf + fd: open multiple files in nvim (Tab to select)
fom() {
  local files
  files=$(fdfind --type f --hidden --exclude .git |
    fzf -m --preview 'batcat --style=numbers --color=always --line-range :100 {} 2>/dev/null || cat {}')
  [ -n "$files" ] && echo "$files" | xargs -d '\n' nvim
}

# ripgrep → fzf: search file contents and jump to line in nvim
frg() {
  local result
  result=$(rg --line-number --no-heading --color=always --smart-case --hidden --glob '!.git' "${1:-}" |
    fzf --ansi --delimiter : \
      --preview 'batcat --style=numbers --color=always --highlight-line {2} {1}' \
      --preview-window 'right,60%,+{2}/2')
  [ -n "$result" ] && {
    local file line
    file=$(echo "$result" | cut -d: -f1)
    line=$(echo "$result" | cut -d: -f2)
    nvim "+${line}" "$file"
  }
}

# fzf + fd: fuzzy cd
# Usage: fcd [-H|-r] [pattern] [path]
#   -H  search from $HOME; -r  search from /
fcd() {
  local default_path="."
  case "${1:-}" in
    -H|--home) default_path="$HOME"; shift ;;
    -r|--root) default_path="/";     shift ;;
  esac
  local dir
  dir=$(fdfind --type d --hidden --exclude .git "${1:-}" "${2:-$default_path}" | fzf) && cd "$dir"
}

eval "$(zoxide init bash)"
eval "$(starship init bash)"

# Machine-local overrides (PATH additions, WSL helpers, work credentials, etc.)
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
