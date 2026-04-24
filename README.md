# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Packages

| Package   | Symlinks created |
|-----------|-----------------|
| `bash`    | `~/.bashrc`, `~/.bashrc.local.example` |
| `git`     | `~/.gitconfig`, `~/.gitconfig.local.example`, `~/.gitignore_global` |
| `starship`| `~/.config/starship.toml` |
| `lazygit` | `~/.config/lazygit/config.yml` |
| `claude`  | `~/.claude/CLAUDE.md`, `~/.claude/rules/`, `~/.claude/settings.json.template` |

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

| File | Purpose |
|------|---------|
| `~/.bashrc.local` | WSL paths, Windows helpers, machine-specific aliases |
| `~/.gitconfig.local` | `[user]` name/email, `[credential]` helper |
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

## Adding a new package

See [docs/adding-package.md](docs/adding-package.md).

## New machine setup

See [docs/new-machine.md](docs/new-machine.md) for the full step-by-step including SSH keys, fnm, uv, Rust, and .NET.
