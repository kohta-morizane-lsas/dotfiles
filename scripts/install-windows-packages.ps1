# Install Windows development tools via winget.
# Run from PowerShell (no admin required for most packages):
#   pwsh -ExecutionPolicy Bypass -File .\scripts\install-windows-packages.ps1
# Already-installed packages are skipped by winget.

$packages = @(
  "Microsoft.PowerShell",      # PowerShell 7
  "Git.Git",
  "GitHub.cli",
  "wez.wezterm",
  "Neovim.Neovim",
  "JesseDuffield.lazygit",
  "Starship.Starship",
  "BurntSushi.ripgrep.MSVC",
  "sharkdp.fd",
  "junegunn.fzf",
  "eza-community.eza",
  "sharkdp.bat",
  "ajeetdsouza.zoxide",
  "Schniz.fnm",
  "Anthropic.ClaudeCode"
)

foreach ($id in $packages) {
  Write-Host "==> winget install $id"
  winget install --id $id -e --accept-package-agreements --accept-source-agreements
}

Write-Host ""
Write-Host "Install the following manually if not yet available:"
Write-Host "  - Nerd Font : JetBrainsMono Nerd Font (https://www.nerdfonts.com)"
Write-Host "  - Rustup    : https://rustup.rs"
Write-Host "  - .NET SDK  : https://dotnet.microsoft.com/download"
Write-Host "  - uv        : pwsh -ExecutionPolicy ByPass -c `"irm https://astral.sh/uv/install.ps1 | iex`""
Write-Host ""
Write-Host "Next: pwsh -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1"
