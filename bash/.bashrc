export EDITOR=nvim
export VISUAL=nvim
export BAT_THEME="tokyonight_storm"

# Resolve tool names once: Ubuntu's apt packages install fdfind/batcat,
# macOS/binary installs provide fd/bat — prefer the upstream names
FD_BIN="$(command -v fd || command -v fdfind)"
BAT_BIN="$(command -v bat || command -v batcat)"

# fzf default search command
export FZF_DEFAULT_COMMAND="$FD_BIN --type f --hidden --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="$FD_BIN --type d --hidden --exclude .git"

alias ls='eza --group-directories-first --icons'
alias ll='eza -l --group-directories-first --icons --git'
alias la='eza -la --group-directories-first --icons --git'
alias lt='eza --tree --icons'
alias lrt='eza -l --group-directories-first --icons --git --sort newest'
alias cat="$BAT_BIN"
alias grep='rg'
alias ff="$FD_BIN"
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

# fzf keybindings (Ctrl+T: files / Ctrl+R: history / Alt+C: cd)
# fzf >= 0.48 supports `fzf --bash`; apt's older fzf ships a key-bindings script
if fzf --bash >/dev/null 2>&1; then
  eval "$(fzf --bash)"
elif [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
  . /usr/share/doc/fzf/examples/key-bindings.bash
fi

# fzf + fd: open file in nvim
# Usage: fo [-H|-r] [path] [pattern]
#   -H  search from $HOME; -r  search from /
fo() {
  local default_path="."
  case "${1:-}" in
  -H | --home)
    default_path="$HOME"
    shift
    ;;
  -r | --root)
    default_path="/"
    shift
    ;;
  esac
  local path="${1:-$default_path}"
  local pattern="${2:-}"
  local file
  file=$("$FD_BIN" --type f --hidden --exclude .git "$pattern" "$path" |
    fzf --preview "$BAT_BIN --style=numbers --color=always --line-range :100 {} 2>/dev/null || cat {}")
  [ -n "$file" ] && nvim "$file"
}

# fzf + fd: open file in $VISUAL (VSCode or other)
fc() {
  local path="${1:-.}"
  local pattern="${2:-}"
  local file
  file=$("$FD_BIN" --type f --hidden --exclude .git "$pattern" "$path" |
    fzf --preview "$BAT_BIN --style=numbers --color=always --line-range :100 {} 2>/dev/null || cat {}")
  [ -n "$file" ] && ${VISUAL:-nvim} "$file"
}

# fzf + fd: open multiple files in nvim (Tab to select)
fom() {
  local files
  files=$("$FD_BIN" --type f --hidden --exclude .git |
    fzf -m --preview "$BAT_BIN --style=numbers --color=always --line-range :100 {} 2>/dev/null || cat {}")
  [ -n "$files" ] && echo "$files" | xargs -d '\n' nvim
}

# ripgrep → fzf: search file contents and jump to line in nvim
frg() {
  local result
  result=$(rg --line-number --no-heading --color=always --smart-case --hidden --glob '!.git' "${1:-}" |
    fzf --ansi --delimiter : \
      --preview "$BAT_BIN --style=numbers --color=always --highlight-line {2} {1}" \
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
  -H | --home)
    default_path="$HOME"
    shift
    ;;
  -r | --root)
    default_path="/"
    shift
    ;;
  esac
  local dir
  dir=$("$FD_BIN" --type d --hidden --exclude .git "${1:-}" "${2:-$default_path}" | fzf) && cd "$dir"
}

ij() {
  command -v nb >/dev/null 2>&1 || { echo "ij: nb is not installed (https://github.com/xwmx/nb)" >&2; return 1; }
  local date_str
  local time_str
  local file
  date_str=$(date +%F)
  time_str=$(date +%H:%M)
  file="${date_str}.md"

  if ! nb daily:ls "$file" >/dev/null 2>&1; then
    nb daily:add --filename "$file" --content "# ${date_str}

  ## Daily Focus

  - Top priority:
  - Definition of Done:
  - Watch-out:

  ## Raw Log

  "
  fi

  nb daily:edit "$file" --content "---

### ${time_str}

- Now:
- Previous:
- Next:
- Blocker:

"

  nb daily:edit "$file"
}

ijeod() {
  command -v nb >/dev/null 2>&1 || { echo "ijeod: nb is not installed (https://github.com/xwmx/nb)" >&2; return 1; }
  local date_str
  local file

  date_str=$(date +%F)
  file="${date_str}.md"

  nb daily:edit "$file" --content "---

  ## End of Day

  - Done:
  - Not done:
  - First thing tomorrow:
  - Return to TODO:

  ---

  ## Corrected English

  ---

  ## Daily Analysis
  "

  nb daily:edit "$file"
}

eval "$(zoxide init bash)"
eval "$(starship init bash)"

# Machine-local overrides (PATH additions, WSL helpers, work credentials, etc.)
[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"
