# New Machine Setup

## 1. SSH key

```bash
ssh-keygen -t ed25519 -C "you@example.com"
cat ~/.ssh/id_ed25519.pub   # paste into GitHub -> Settings -> SSH keys
```

## 2. Clone dotfiles

```bash
git clone git@github.com:YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

## 3. Bootstrap system tools

```bash
bash scripts/bootstrap.sh
```

Installs: `stow`, `git`, `ripgrep`, `fd`, `fzf`, `bat`, `eza`, `zoxide`, `neovim`, `lazygit`, `starship`.

Install sources (Ubuntu's apt repos are not enough for everything):

- `eza` — official deb repo (deb.gierens.de); the version in Ubuntu universe is outdated
- `lazygit` — GitHub releases binary → `/usr/local/bin` (not packaged for Ubuntu)
- `neovim` — official tarball → `/opt/nvim-linux-x86_64` + symlink (apt's 0.9.x is too old for LazyVim)
- everything else — apt

## 4. Install dotfiles

```bash
./install.sh --all
```

## 5. Machine-local config

```bash
# Git identity
git config -f ~/.gitconfig.local user.name  'Your Name'
git config -f ~/.gitconfig.local user.email 'you@example.com'

# WSL paths and Windows helpers
cp ~/.bashrc.local.example ~/.bashrc.local
# Edit ~/.bashrc.local and uncomment the WSL-specific sections
```

## 6. Language runtimes (install manually)

### Node (fnm)
```bash
curl -fsSL https://fnm.vercel.app/install | bash
source ~/.bashrc
fnm install --lts
```

### Python (uv)
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### Rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### .NET

Install with the official script so the SDK lands in `~/.dotnet` (matches the `DOTNET_ROOT` in `bash/.bashrc.local.example`). **Do not use `apt-get install dotnet-sdk-*`** — that installs to `/usr/share/dotnet`, which mismatches `DOTNET_ROOT=$HOME/.dotnet` and causes `dotnet ef` and other global tools to fail with "could not find any compatible framework version".

```bash
curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
chmod +x /tmp/dotnet-install.sh
/tmp/dotnet-install.sh --channel 9.0
```

Enable the `.NET` section in `~/.bashrc.local` (uncomment these lines):
```bash
export DOTNET_ROOT="$HOME/.dotnet"
export PATH="$PATH:$HOME/.dotnet:$HOME/.dotnet/tools"
```

Reload the shell and verify:
```bash
exec bash
which dotnet            # → ~/.dotnet/dotnet
dotnet --info           # SDK + runtime listed
```

Global tools (install after `DOTNET_ROOT` is set):
```bash
dotnet tool install --global dotnet-ef
```

If `dotnet` was previously installed via `apt` or to `/usr/local/bin`, remove or unlink it first so `~/.dotnet/dotnet` wins on `PATH`.

## 7. Neovim config

Installed by `./install.sh --all` as the `nvim` stow package (symlinked to `~/.config/nvim`,
plus `~/.markdownlint-cli2.yaml` for the markdown linter).
On first launch, lazy.nvim downloads plugins automatically — verify with `:LazyHealth`.

## 8. gh CLI

```bash
sudo apt-get install -y gh
gh auth login
```
