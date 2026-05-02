# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package    | Symlinks created                                                              |
| ---------- | ----------------------------------------------------------------------------- |
| `bash`     | `~/.bashrc`, `~/.bashrc.local.example`                                        |
| `git`      | `~/.gitconfig`, `~/.gitconfig.local.example`, `~/.gitignore_global`           |
| `starship` | `~/.config/starship.toml`                                                     |
| `lazygit`  | `~/.config/lazygit/config.yml`                                                |
| `claude`   | `~/.claude/CLAUDE.md`, `~/.claude/rules/`, `~/.claude/settings.json.template` |

**Not managed here:**

- `~/.config/nvim/` — managed as its own git repo
- `~/tools/` — managed separately

## Quick Start (new machine)

```bash
git clone git@github.com:YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
bash scripts/bootstrap.sh    # install stow + CLI tools
./install.sh --all            # back up existing dotfiles and stow all packages
```

Then fill in machine-local values:

```bash
# Git identity
git config -f ~/.gitconfig.local user.name  'Your Name'
git config -f ~/.gitconfig.local user.email 'you@example.com'

# WSL-specific paths (copy and edit)
cp ~/.bashrc.local.example ~/.bashrc.local
$EDITOR ~/.bashrc.local
```

## Machine-local files (not tracked by git)

| File                      | Purpose                                                      |
| ------------------------- | ------------------------------------------------------------ |
| `~/.bashrc.local`         | WSL paths, Windows helpers, machine-specific aliases         |
| `~/.gitconfig.local`      | `[user]` name/email, `[credential]` helper                   |
| `~/.claude/settings.json` | Claude Code settings (copied from template on first install) |

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

## Shell functions (`bash/.bashrc`)

### fzf-powered navigation

| Command                | Description                                                  |
| ---------------------- | ------------------------------------------------------------ |
| `fo [path] [pattern]`  | Fuzzy-find a file and open in `nvim`                         |
| `fc [path] [pattern]`  | Fuzzy-find a file and open in `$VISUAL`                      |
| `fom`                  | Fuzzy-find multiple files (Tab to select) and open in `nvim` |
| `frg [query]`          | Search file contents with ripgrep, jump to line in `nvim`    |
| `fcd [pattern] [path]` | Fuzzy `cd` into a directory                                  |

#### Search scope flags (`fo`, `fcd`)

By default these search the current directory. Use a flag to widen the scope:

| Flag            | Search root             |
| --------------- | ----------------------- |
| _(none)_        | `.` (current directory) |
| `-H` / `--home` | `$HOME`                 |
| `-r` / `--root` | `/` (filesystem root)   |

```bash
fo -H              # pick any file under $HOME, open in nvim
fo -r pattern      # pick a file matching "pattern" anywhere on /, open in nvim
fcd -H             # fuzzy-cd to any directory under $HOME
fcd -r src         # fuzzy-cd to a directory named "src" anywhere on /
```

## Adding a new package

See [docs/adding-package.md](docs/adding-package.md).

## New machine setup

See [docs/new-machine.md](docs/new-machine.md) for the full step-by-step including SSH keys, fnm, uv, Rust, and .NET.
