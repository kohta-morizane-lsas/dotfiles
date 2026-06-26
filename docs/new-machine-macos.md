# New Machine Setup (macOS)

## 1. SSH key

```bash
ssh-keygen -t ed25519 -C "you@example.com"
cat ~/.ssh/id_ed25519.pub   # add to GitHub → Settings → SSH keys
```

## 2. Clone dotfiles

```bash
git clone git@github.com:YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

## 3. Bootstrap (Homebrew + CLI tools + font)

```bash
bash scripts/bootstrap.sh
```

Installs Homebrew if missing, then runs `brew bundle` from `./Brewfile`.

Tools installed: `stow`, `git`, `ripgrep`, `fd`, `fzf`, `bat`, `eza`, `zoxide`, `neovim`,
`lazygit`, `starship`, `gh`, plus the cask `font-jetbrains-mono-nerd-font`.

## 4. Install dotfiles

```bash
./install.sh --all
```

Backs up existing `~/.zshrc`, `~/.bashrc`, `~/.gitconfig`, `~/.config/nvim`,
`~/.config/shell` to `~/.dotfiles-backup-<timestamp>/`, then stows:
`bash zsh shell git starship lazygit nvim bat`.

## 5. Login shell

macOS default is already zsh — no `chsh` needed.
Open a new terminal to load `~/.zshrc`.

## 6. Machine-local config

```bash
git config -f ~/.gitconfig.local user.name  'Your Name'
git config -f ~/.gitconfig.local user.email 'you@example.com'

# Optional: add macOS-specific PATH or env vars
cp ~/.zshrc.local.example ~/.zshrc.local
```

## 7. Language runtimes (install as needed)

### Node (fnm)

```bash
curl -fsSL https://fnm.vercel.app/install | bash
```

### Python (uv)

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## 8. Verify

- `fo` / `fc` / `fom` / `frg` / `fcd` work
- `ls` (eza), `cat` (bat), `g` (lazygit), `v` (nvim)
- starship prompt, `z` (zoxide), `Ctrl+T` / `Ctrl+R` (fzf)
- nvim → `:LazyHealth` clean
- `git config --get user.email` returns your machine-local value
