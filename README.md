# dotfiles

Personal dotfiles for **WSL Ubuntu** (managed with [GNU Stow](https://www.gnu.org/software/stow/))
and **Windows + PowerShell 7** (deployed via `scripts/install-windows.ps1`).

Goal: a Unix-like development environment that feels the same whether you are in
WSL or native Windows — same tools, same aliases, same key habits.

## Packages (WSL — stow)

| Package    | Symlinks created                                                    |
| ---------- | ------------------------------------------------------------------- |
| `bash`     | `~/.bashrc`, `~/.bashrc.local.example`                              |
| `git`      | `~/.gitconfig`, `~/.gitconfig.local.example`, `~/.gitignore_global` |
| `starship` | `~/.config/starship.toml`                                           |
| `lazygit`  | `~/.config/lazygit/config.yml`                                      |
| `nvim`     | `~/.config/nvim/` (LazyVim config, `lazy-lock.json` included), `~/.markdownlint-cli2.yaml` |
| `bat`      | `~/.config/bat/themes/tokyonight_storm.tmTheme`                     |

## Windows configs (deployed by `install-windows.ps1`)

| Repo file                                     | Symlink target                            |
| --------------------------------------------- | ----------------------------------------- |
| `wezterm/.wezterm.lua`                        | `%USERPROFILE%\.wezterm.lua`              |
| `powershell/Microsoft.PowerShell_profile.ps1` | `$PROFILE`                                |
| `starship/.config/starship.toml`              | `%USERPROFILE%\.config\starship.toml`     |
| `nvim/.config/nvim/`                          | `%LOCALAPPDATA%\nvim`                     |
| `nvim/.markdownlint-cli2.yaml`                | `%USERPROFILE%\.markdownlint-cli2.yaml`   |
| `lazygit/.config/lazygit/config.yml`          | `%LOCALAPPDATA%\lazygit\config.yml`       |
| `git/.gitconfig`                              | `%USERPROFILE%\.gitconfig`                |
| `git/.gitignore_global`                       | `%USERPROFILE%\.gitignore_global`         |
| `bat/.config/bat/themes/tokyonight_storm.tmTheme` | `%APPDATA%\bat\themes\tokyonight_storm.tmTheme` |

`starship`, `nvim`, `lazygit`, `git`, and `bat` are shared between WSL and Windows —
same files, different link targets.

**Not managed here:**

- `~/tools/` — managed separately
- Claude Code — installed and configured manually, outside dotfiles

## Quick Start (new machine)

### WSL Ubuntu

```bash
git clone git@github.com:YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash scripts/bootstrap.sh    # install stow + CLI tools (lazygit/neovim from GitHub releases)
./install.sh --all            # back up existing dotfiles and stow all packages
```

### Windows (PowerShell 7)

Clone with `git clone` (not ZIP — avoids Mark-of-the-Web script blocking), then
run the package installer with built-in Windows PowerShell first (pwsh does not
exist yet on a fresh machine):

```powershell
git clone git@github.com:YOUR_USERNAME/dotfiles.git $env:USERPROFILE\dotfiles
cd $env:USERPROFILE\dotfiles
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows-packages.ps1  # winget bulk install
pwsh -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1                 # symlink configs
```

Full steps: [docs/new-machine-windows.md](docs/new-machine-windows.md)

Then fill in machine-local values:

```bash
# Git identity (same on WSL and Windows)
git config -f ~/.gitconfig.local user.name  'Your Name'
git config -f ~/.gitconfig.local user.email 'you@example.com'

# WSL-specific paths (copy and edit)
cp ~/.bashrc.local.example ~/.bashrc.local
$EDITOR ~/.bashrc.local
```

## Machine-local files (not tracked by git)

| File                                     | Purpose                                               |
| ---------------------------------------- | ----------------------------------------------------- |
| `~/.bashrc.local`                        | WSL paths, Windows helpers, machine-specific aliases  |
| `~/.gitconfig.local`                     | `[user]` name/email, `[credential]` helper            |
| `Documents\PowerShell\profile.local.ps1` | Windows: WSL home shortcut, PowerToys module, tool aliases |

## Common operations

```bash
# Install a single package
./install.sh bash

# Preview without making changes
./install.sh --all --dry-run

# Remove symlinks (keeps backup)
./install.sh --all --unstow

# Add a new dotfile to an existing package
mv ~/.some/config dotfiles/bash/.some/config
./install.sh bash
```

## Shell functions

Defined in `bash/.bashrc` (WSL) and `powershell/Microsoft.PowerShell_profile.ps1`
(Windows). The core set behaves the same in both shells:

### fzf-powered navigation (both shells)

| Command                | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| `fo [path] [pattern]`  | Fuzzy-find a file (with preview) and open in `nvim`          |
| `fc [path] [pattern]`  | Fuzzy-find a file and open in `$VISUAL` (fallback: `nvim`)   |
| `fom`                  | Fuzzy-find multiple files (Tab to select) and open in `nvim` |
| `frg [query]`          | Search file contents with ripgrep, jump to line in `nvim`    |
| `fcd [pattern] [path]` | Fuzzy `cd` into a directory                                  |

`Ctrl+T` (insert file path) and `Ctrl+R` (history) work in both shells:
bash loads the fzf keybindings, PowerShell uses the PSFzf module.

#### Search scope flags (`fo`, `fcd`)

By default these search the current directory. Use a flag to widen the scope:

| Flag (bash)     | Flag (pwsh) | Search root                  |
| --------------- | ----------- | ---------------------------- |
| _(none)_        | _(none)_    | `.` (current directory)      |
| `-H` / `--home` | `-H`        | `$HOME`                      |
| `-r` / `--root` | `-R`        | `/` (WSL) / drive root (Win) |

```bash
fo -H              # pick any file under $HOME, open in nvim
fo -r pattern      # pick a file matching "pattern" anywhere on /, open in nvim
fcd -H             # fuzzy-cd to any directory under $HOME
fcd -r src         # fuzzy-cd to a directory named "src" anywhere on /
```

### Windows-only helpers (PowerShell)

| Command          | Description                                          |
| ---------------- | ---------------------------------------------------- |
| `fos` / `fosm`   | Fuzzy-find file(s) and open with the default app     |
| `fop` `fox` `fod` `fopd` | Same, filtered to pptx / xlsx / docx / pdf   |
| `fe` / `e`       | Pick / open a directory in Explorer                  |

WSL equivalents of `e` / `fe` (via `explorer.exe` + `wslpath`) are available as
commented-out examples in `~/.bashrc.local.example`.

## Adding a new package

See [docs/adding-package.md](docs/adding-package.md).

## New machine setup

- WSL: [docs/new-machine.md](docs/new-machine.md) — SSH keys, fnm, uv, Rust, and .NET
- Windows: [docs/new-machine-windows.md](docs/new-machine-windows.md) — winget packages, symlinks, execution policy
