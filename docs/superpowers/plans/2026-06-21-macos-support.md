# macOS Support + Environment Rebuild Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the dotfiles repo first-class on macOS (zsh login shell, Brewfile, shared shell logic) without breaking the existing WSL/bash setup, and document the clean-rebuild migration.

**Architecture:** Extract all bash/zsh-common config (aliases, env vars, fzf/fd functions) into a POSIX-compatible `shell/.config/shell/common.sh` sourced by both `.bashrc` and a new `.zshrc`. Each rc keeps only shell-specific init (`fzf --bash/--zsh`, `zoxide/starship/fnm` init). macOS CLI tools + Nerd Font move to a `Brewfile` driven by `brew bundle`. Machine-specific cruft currently committed in `.bashrc` moves to `*.local` examples.

**Tech Stack:** GNU Stow, Homebrew (`brew bundle`), bash, zsh, POSIX sh, fzf/fd/ripgrep/bat/eza/zoxide/neovim/lazygit/starship.

## Global Constraints

- Reset scope is **development environment only** — never reinstall/erase macOS, never uninstall Homebrew itself.
- Login shell on macOS is **zsh** (already the default; no `chsh` needed).
- Package management covers **CLI tools + fonts only** — no GUI app casks (no WezTerm/VS Code/browser).
- Shared shell logic lives in **`shell/.config/shell/common.sh`** (POSIX sh compatible), sourced by both rc files. Shell-specific `init` evals stay in the rc files.
- **Behavior parity is mandatory:** after refactor, bash must produce identical aliases/functions/env vars as before (WSL regression guard).
- **No machine-specific values in tracked files** — they go to `*.local` (already gitignored via `*.local`).
- Portability: replace GNU-only `xargs -d '\n'` with NUL-delimited (`fd -0` / `fzf --read0 --print0` / `xargs -0`) so it works on BSD/macOS and GNU/Linux.
- Mirror exact `$HOME`-relative paths inside each stow package.

---

### Task 1: Extract shared shell logic into `shell/common.sh`

**Files:**
- Create: `shell/.config/shell/common.sh`
- Reference (do not modify yet): `bash/.bashrc:1-24,45-193`

**Interfaces:**
- Produces: a POSIX-sourceable file defining env vars `EDITOR`, `VISUAL`, `BAT_THEME`, `FD_BIN`, `BAT_BIN`, `FZF_DEFAULT_COMMAND`, `FZF_CTRL_T_COMMAND`, `FZF_ALT_C_COMMAND`; aliases `ls ll la lt lrt cat grep ff g v`; functions `fo fc fom frg fcd ij ijeod`. Consumed by Task 3 (`.bashrc`) and Task 4 (`.zshrc`).
- Does NOT contain: `zoxide/starship/fnm/fzf` init evals, Rust `cargo/env`, or any `*.local` sourcing (those stay per-shell).

- [ ] **Step 1: Create the shared file**

Copy the shared content from `bash/.bashrc` verbatim EXCEPT the one portability fix in `fom` (Step 2). Include exactly these blocks (current `.bashrc` line ranges in parentheses):

```sh
# Shared bash/zsh config — sourced by ~/.bashrc and ~/.zshrc.
# Keep POSIX sh compatible (no bashisms / no zsh-isms).

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
```

Then append, verbatim from `bash/.bashrc:48-99` and `104-190`, the functions `fo`, `fc`, `fom` (with the Step 2 fix), `frg`, `fcd`, `ij`, `ijeod`.

- [ ] **Step 2: Apply the portability fix in `fom`**

Replace the GNU-only `fom` body (currently `bash/.bashrc:79-84`) with a NUL-delimited version that works on both BSD (macOS) and GNU (Linux):

```sh
# fzf + fd: open multiple files in nvim (Tab to select)
fom() {
  "$FD_BIN" --type f --hidden --exclude .git -0 |
    fzf -m --read0 --print0 \
      --preview "$BAT_BIN --style=numbers --color=always --line-range :100 {} 2>/dev/null || cat {}" |
    xargs -0 -o nvim
}
```

Notes: `-o` keeps stdin attached to the terminal so nvim opens interactively after the pipe. `--read0/--print0` keep NUL framing end-to-end (safe for filenames with spaces/newlines).

- [ ] **Step 3: Verify the file sources cleanly in bash**

Run: `bash -c 'set -e; . shell/.config/shell/common.sh; type fo fom frg fcd; alias ls'`
Expected: prints function definitions for `fo fom frg fcd` and the `ls` alias, exit 0, no errors.

- [ ] **Step 4: Verify the file sources cleanly in zsh**

Run: `zsh -c 'emulate -L sh; . shell/.config/shell/common.sh; whence -v fo fom; alias ls'`
Expected: reports `fo`/`fom` as functions and the `ls` alias, no errors.

- [ ] **Step 5: Commit**

```bash
git add shell/.config/shell/common.sh
git commit -m "feat(shell): extract shared bash/zsh config into common.sh"
```

---

### Task 2: Move machine-specific cruft out of `.bashrc` into the local example

**Files:**
- Modify: `bash/.bashrc:194-209` (remove machine-specific tail)
- Modify: `bash/.bashrc.local.example` (append退避 examples)

**Interfaces:**
- Consumes: nothing.
- Produces: a `.bashrc` whose tracked tail contains no machine-specific paths; the退避 content preserved as commented examples in `.bashrc.local.example`.

- [ ] **Step 1: Delete the machine-specific tail from `bash/.bashrc`**

Remove these lines (currently `bash/.bashrc:198-208`) entirely:

```sh
. "$HOME/.local/bin/env"
export PATH=/usr/local/cuda/bin:$PATH
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Load Angular CLI autocompletion.
source <(ng completion script)

# VsCode setting
code() {
  "/mnt/c/Users/Kohta-Morizane/AppData/Local/Programs/Microsoft VS Code/bin/code" --remote wsl+Ubuntu "${1:-.}" 2>/dev/null
}
```

Leave the existing `[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"` line (currently `:196`) in place — it stays as the final tracked line.

- [ ] **Step 2: Append the退避 examples to `bash/.bashrc.local.example`**

Add to the end of `bash/.bashrc.local.example` (these are WSL-only; guarded so they no-op elsewhere):

```sh
# --- uv (Python) env ---
# [ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# --- CUDA (Linux/WSL with NVIDIA only) ---
# export PATH="/usr/local/cuda/bin:$PATH"
# export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"

# --- Angular CLI completion (only if `ng` is installed) ---
# command -v ng >/dev/null 2>&1 && source <(ng completion script)

# --- VS Code launcher (WSL: open current dir in Windows VS Code) ---
# code() {
#   "/mnt/c/Users/Kohta-Morizane/AppData/Local/Programs/Microsoft VS Code/bin/code" \
#     --remote wsl+Ubuntu "${1:-.}" 2>/dev/null
# }
```

- [ ] **Step 3: Verify `.bashrc` tail is clean**

Run: `grep -nE 'cuda|ng completion|Microsoft VS Code|local/bin/env' bash/.bashrc`
Expected: no matches (exit 1).

- [ ] **Step 4: Commit**

```bash
git add bash/.bashrc bash/.bashrc.local.example
git commit -m "refactor(bash): move machine-specific cruft to .bashrc.local.example"
```

---

### Task 3: Slim `.bashrc` down to bash-specific init + source common.sh

**Files:**
- Modify: `bash/.bashrc` (replace shared body with a source line)

**Interfaces:**
- Consumes: `shell/.config/shell/common.sh` (Task 1) via `~/.config/shell/common.sh`.
- Produces: a `.bashrc` containing only: source of common.sh, Rust env, fnm bash init, fzf bash keybindings, zoxide/starship bash init, and `.bashrc.local` source. Behavior must match pre-refactor bash.

- [ ] **Step 1: Rewrite `bash/.bashrc`**

Replace the entire file with:

```sh
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
```

- [ ] **Step 2: Verify behavior parity (aliases/functions/env)**

Compare the set of aliases and functions produced by sourcing the new chain vs. what `common.sh` defines. Run:

```bash
bash -c 'set -e; . shell/.config/shell/common.sh; alias > /tmp/a_aliases.txt; typeset -F | grep -E " (fo|fc|fom|frg|fcd|ij|ijeod)$"'
```
Expected: lists all seven functions; `/tmp/a_aliases.txt` contains `ls`, `cat`, `g`, `v`, etc. No errors.

- [ ] **Step 3: Verify `.bashrc` has no leftover shared definitions**

Run: `grep -nE "alias (ls|cat)=|^fo\(\)|FZF_DEFAULT_COMMAND" bash/.bashrc`
Expected: no matches (exit 1) — those now live only in common.sh.

- [ ] **Step 4: Commit**

```bash
git add bash/.bashrc
git commit -m "refactor(bash): source common.sh, keep only bash-specific init"
```

---

### Task 4: Add the `zsh` package (`.zshrc` + local example)

**Files:**
- Create: `zsh/.zshrc`
- Create: `zsh/.zshrc.local.example`

**Interfaces:**
- Consumes: `shell/.config/shell/common.sh` (Task 1) via `~/.config/shell/common.sh`.
- Produces: a zsh login config with zsh-specific init (compinit, `fzf --zsh`, `zoxide/starship/fnm` zsh init) + common.sh + `.zshrc.local` source.

- [ ] **Step 1: Create `zsh/.zshrc`**

```sh
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
```

- [ ] **Step 2: Create `zsh/.zshrc.local.example`**

```sh
# Machine-local zsh overrides — copy to ~/.zshrc.local and customise.
# This file is NOT tracked by git (*.local is gitignored).

# --- Extra PATH entries ---
# export PATH="$HOME/.local/bin:$PATH"

# --- uv (Python) env ---
# [ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# --- Work credentials / aliases ---
```

- [ ] **Step 3: Verify `.zshrc` parses and sources without error**

Run (use a throwaway HOME so it doesn't touch your real config, and point common.sh at the repo copy):

```bash
zsh -c 'set -e; . shell/.config/shell/common.sh; autoload -Uz compinit && compinit -C; whence -w fo fom frg; echo OK'
```
Expected: prints `fo: function` etc. and `OK`, exit 0.

- [ ] **Step 4: Commit**

```bash
git add zsh/.zshrc zsh/.zshrc.local.example
git commit -m "feat(zsh): add zsh package sourcing common.sh"
```

---

### Task 5: Add the `Brewfile` and switch `bootstrap.sh` macOS path to `brew bundle`

**Files:**
- Create: `Brewfile`
- Modify: `scripts/bootstrap.sh:83-95` (`install_macos`)

**Interfaces:**
- Consumes: `$DOTFILES_DIR` (already defined in bootstrap as the repo root via `BASH_SOURCE`). Note bootstrap computes dir differently — see Step 2.
- Produces: `brew bundle`-driven macOS install of the CLI tool set + Nerd Font.

- [ ] **Step 1: Create `Brewfile`**

```ruby
# CLI tools (shared dev environment)
brew "stow"
brew "git"
brew "ripgrep"
brew "fd"
brew "fzf"
brew "bat"
brew "eza"
brew "zoxide"
brew "neovim"
brew "lazygit"
brew "starship"
brew "gh"

# Fonts (Nerd Font for terminal + nvim icons)
cask "font-jetbrains-mono-nerd-font"
```

- [ ] **Step 2: Rewrite `install_macos()` in `scripts/bootstrap.sh`**

`bootstrap.sh` does not currently define a repo-root variable, so compute it locally. Replace the `install_macos()` body (currently `scripts/bootstrap.sh:83-95`) with:

```sh
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
```

- [ ] **Step 3: Validate the Brewfile (no install)**

Run: `brew bundle check --file=Brewfile || true`
Expected: either "The Brewfile's dependencies are satisfied" or a list of missing deps — but NO parse error / "Invalid Brewfile".

- [ ] **Step 4: Lint the bootstrap script**

Run: `bash -n scripts/bootstrap.sh`
Expected: exit 0 (no syntax errors).

- [ ] **Step 5: Commit**

```bash
git add Brewfile scripts/bootstrap.sh
git commit -m "feat(macos): manage CLI tools + font via Brewfile"
```

---

### Task 6: Register `shell` + `zsh` packages and back up `~/.zshrc` / `~/.config/shell`

**Files:**
- Modify: `install.sh:6` (`ALL_PACKAGES`)
- Modify: `scripts/backup-existing.sh:23-31,42-50`

**Interfaces:**
- Consumes: the `shell` (Task 1) and `zsh` (Task 4) package directories.
- Produces: `install.sh --all` that stows `shell` + `zsh`; `backup-existing.sh` that relocates pre-existing `~/.zshrc` and `~/.config/shell` before stowing.

- [ ] **Step 1: Add packages to `install.sh`**

Change `install.sh:6` from:

```sh
ALL_PACKAGES=(bash git starship lazygit nvim bat)
```
to:
```sh
ALL_PACKAGES=(bash zsh shell git starship lazygit nvim bat)
```

- [ ] **Step 2: Add `~/.zshrc` to the backup file list**

In `scripts/backup-existing.sh`, add `"$HOME/.zshrc"` to the `FILES_TO_BACKUP` array (after `"$HOME/.bashrc"`).

- [ ] **Step 3: Back up `~/.config/shell` directory**

After the existing nvim-directory backup block (`scripts/backup-existing.sh:42-50`), add an analogous block:

```sh
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
```

- [ ] **Step 4: Lint both scripts**

Run: `bash -n install.sh scripts/backup-existing.sh`
Expected: exit 0.

- [ ] **Step 5: Dry-run stow of the new packages**

Run: `./install.sh shell zsh --dry-run`
Expected: stow `-n` output showing planned links for `~/.config/shell/common.sh`, `~/.zshrc`, `~/.zshrc.local.example`; no "existing target is not owned by stow" conflicts (or, if `~/.zshrc` is a real file, that is expected — it will be backed up on a real run).

- [ ] **Step 6: Commit**

```bash
git add install.sh scripts/backup-existing.sh
git commit -m "feat(install): register shell + zsh packages, back up zsh config"
```

---

### Task 7: Documentation — macOS new-machine guide + README + migration runbook

**Files:**
- Create: `docs/new-machine-macos.md`
- Modify: `README.md` (Quick Start, Packages table, shared-config note, New machine links)

**Interfaces:**
- Consumes: the finished behavior of Tasks 1-6 (Brewfile, `install.sh --all`, packages).
- Produces: end-user docs for macOS setup and the reset→rebuild runbook.

- [ ] **Step 1: Write `docs/new-machine-macos.md`**

Include these sections with concrete commands (no placeholders):

```markdown
# New Machine Setup (macOS)

## 1. SSH key
ssh-keygen -t ed25519 -C "you@example.com"
cat ~/.ssh/id_ed25519.pub   # add to GitHub → Settings → SSH keys

## 2. Clone dotfiles
git clone git@github.com:YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles

## 3. Bootstrap (Homebrew + CLI tools + font)
bash scripts/bootstrap.sh
# Installs Homebrew if missing, then `brew bundle` from ./Brewfile
# (stow git ripgrep fd fzf bat eza zoxide neovim lazygit starship gh + JetBrainsMono Nerd Font).

## 4. Install dotfiles
./install.sh --all
# Backs up existing ~/.zshrc, ~/.bashrc, ~/.gitconfig, ~/.config/nvim, ~/.config/shell to
# ~/.dotfiles-backup-<timestamp>/, then stows: bash zsh shell git starship lazygit nvim bat.

## 5. Login shell
# macOS default is already zsh — no `chsh` needed. Open a new terminal to load ~/.zshrc.

## 6. Machine-local config
git config -f ~/.gitconfig.local user.name  'Your Name'
git config -f ~/.gitconfig.local user.email 'you@example.com'
cp ~/.zshrc.local.example ~/.zshrc.local   # optional: add macOS-specific PATH etc.

## 7. Language runtimes (install as needed)
curl -fsSL https://fnm.vercel.app/install | bash      # Node
curl -LsSf https://astral.sh/uv/install.sh | sh       # Python
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh   # Rust

## 8. Verify
# - fo / fc / fom / frg / fcd work
# - ls (eza), cat (bat), g (lazygit), v (nvim)
# - starship prompt, z (zoxide), Ctrl+T / Ctrl+R (fzf)
# - nvim → :LazyHealth clean
# - git config --get user.email returns your machine-local value
```

- [ ] **Step 2: Update `README.md`**

Make these edits:
- Line 3-7 intro: add macOS to the supported platforms sentence.
- Packages table (around `README.md:11-18`): add rows for `zsh` (`~/.zshrc`, `~/.zshrc.local.example`) and `shell` (`~/.config/shell/common.sh`).
- Add a one-line note: "`shell` holds aliases/functions shared by bash and zsh; `bash` and `zsh` each add only shell-specific init."
- Quick Start: add a "### macOS" subsection mirroring the WSL one but using `brew bundle` and zsh, linking to `docs/new-machine-macos.md`.
- New machine setup list (around `README.md:155-158`): add the macOS doc link.

- [ ] **Step 3: Verify markdown lints (if linter available)**

Run: `command -v markdownlint-cli2 >/dev/null && markdownlint-cli2 docs/new-machine-macos.md README.md || echo "linter not installed, skip"`
Expected: no lint errors, or the skip message.

- [ ] **Step 4: Commit**

```bash
git add docs/new-machine-macos.md README.md
git commit -m "docs(macos): add new-machine guide and README macOS section"
```

---

### Task 8: End-to-end verification on this macOS machine (the rebuild)

**Files:** none (operational task — executes the migration runbook from the spec).

**Interfaces:**
- Consumes: everything from Tasks 1-7.
- Produces: a verified, dotfiles-managed macOS environment.

- [ ] **Step 1: Phase 0 — record current state**

```bash
brew leaves > ~/brew-leaves-backup.txt
brew list --cask > ~/brew-casks-backup.txt 2>/dev/null || true
git -C ~/dotfiles config --get user.email 2>/dev/null || cat ~/.gitconfig | grep -A2 '\[user\]' || true
```
Expected: backup files written; note the existing git user.name/email if present.

- [ ] **Step 2: Phase 2 — bootstrap (idempotent; Homebrew already present)**

Run: `bash scripts/bootstrap.sh`
Expected: `brew bundle` completes; `bat eza zoxide neovim lazygit starship gh fzf fd ripgrep stow` all installed; Nerd Font cask installed.

- [ ] **Step 3: Phase 2 — install dotfiles**

Run: `./install.sh --all`
Expected: backup script relocates the real `~/.zshrc`/`~/.bashrc`/`~/.gitconfig`/`~/.config/nvim` to `~/.dotfiles-backup-<ts>/`; stow creates symlinks; bat theme cache rebuilt; `~/.gitconfig.local` created from example.

- [ ] **Step 4: Phase 2 — machine-local git identity**

```bash
git config -f ~/.gitconfig.local user.name  'Your Name'
git config -f ~/.gitconfig.local user.email 'you@example.com'
```
Expected: `git config --get user.email` (in a new shell) returns the value.

- [ ] **Step 5: Phase 3 — verify shell in a fresh zsh**

Run: `zsh -ic 'whence -w fo fom frg fcd; alias ls; alias cat; command -v starship zoxide fzf'`
Expected: functions reported, `ls`/`cat` aliases present, starship/zoxide/fzf resolve. No errors.

- [ ] **Step 6: Phase 3 — verify symlinks point into the repo**

Run: `ls -l ~/.zshrc ~/.config/shell/common.sh ~/.config/starship.toml ~/.config/nvim`
Expected: all are symlinks into `~/dotfiles/...`.

- [ ] **Step 7: Phase 3 — verify nvim**

Run: `nvim --headless "+Lazy! sync" +qa` then `nvim --headless "+checkhealth" +qa 2>&1 | tail -20`
Expected: plugins sync; checkhealth reports no critical errors for core (lazy, treesitter). (LSP/runtime warnings for not-yet-installed languages are acceptable.)

- [ ] **Step 8: No commit (operational)**

This task changes the machine, not the repo. If any fix to repo files is needed, loop back to the relevant task.

---

## Self-Review

**Spec coverage:**
- §5 A-1 common.sh → Task 1 ✓; `.bashrc` slim → Task 3 ✓; machine-cruft退避 → Task 2 ✓; `.zshrc` → Task 4 ✓; portability `xargs -d` fix → Task 1 Step 2 ✓.
- §5 A-2 Brewfile + bootstrap → Task 5 ✓.
- §5 A-3 install.sh ALL_PACKAGES → Task 6 ✓.
- §5 A-4 backup-existing → Task 6 ✓.
- §5 A-5 docs → Task 7 ✓.
- §5 B migration runbook (Phase 0-3) → Task 8 ✓.
- §6 test strategy (bash parity, brew bundle check, stow dry-run) → Tasks 1,3,5,6 ✓.

**Placeholder scan:** No TBD/TODO; every code step shows full content. The only intentional user-supplied values are git name/email (`'Your Name'` / `you@example.com`) and `YOUR_USERNAME` in clone URLs, which are genuine per-user inputs, not plan gaps.

**Type/name consistency:** Function names `fo/fc/fom/frg/fcd/ij/ijeod` and alias names used identically across Tasks 1,3,4,5,8. `common.sh` path `~/.config/shell/common.sh` consistent across Tasks 1,3,4,6,8. `ALL_PACKAGES` order consistent.

**Note for executor:** Tasks 1-7 are repo changes (commit each). Task 8 mutates this machine and is destructive-ish (relocates real dotfiles to a backup dir) — run it only after Tasks 1-7 are merged/verified, and confirm the backup dir contents before discarding anything.
