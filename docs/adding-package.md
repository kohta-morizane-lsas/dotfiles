# Adding a New Package

## Add a file to an existing package

```bash
# Example: add ~/.config/gh/config.yml to the git package
mkdir -p ~/dotfiles/git/.config/gh
mv ~/.config/gh/config.yml ~/dotfiles/git/.config/gh/config.yml
cd ~/dotfiles
./install.sh git
```

## Create a new package

```bash
# 1. Create the package directory mirroring $HOME paths
mkdir -p ~/dotfiles/tmux

# 2. Move the config file(s) into it
mv ~/.tmux.conf ~/dotfiles/tmux/.tmux.conf

# 3. Stow it
cd ~/dotfiles
./install.sh tmux
```

## Register the new package in install.sh

Edit the `ALL_PACKAGES` array at the top of `install.sh`:

```bash
ALL_PACKAGES=(bash git starship lazygit claude tmux)
```

## Verify with dry-run first

```bash
./install.sh tmux --dry-run
```

## Update README.md

Add a row to the Packages table in `README.md`.

## Rules of thumb

- Mirror the exact path from `$HOME`. If the file lives at `~/.config/foo/bar.toml`, put it at `dotfiles/mypkg/.config/foo/bar.toml`.
- Keep one concern per package -- don't mix unrelated tools.
- Never put machine-specific values in tracked files; use `*.local` files instead.
- Add new `*.local` patterns to `.gitignore` if needed.
