# Install Windows development tools via winget.
# On a fresh machine pwsh (PowerShell 7) does not exist yet — run the first time
# with built-in Windows PowerShell (no admin required for most packages):
#   powershell -ExecutionPolicy Bypass -File .\scripts\install-windows-packages.ps1
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
  "Schniz.fnm"
)

foreach ($id in $packages) {
  Write-Host "==> winget install $id"
  winget install --id $id -e --accept-package-agreements --accept-source-agreements
}

# PSFzf — fzf keybindings (Ctrl+T / Ctrl+R) for PowerShell; loaded by the profile
if (-not (Get-Module -ListAvailable -Name PSFzf)) {
  Write-Host "==> Install-Module PSFzf"
  Install-Module PSFzf -Scope CurrentUser -Force
}

Write-Host ""
Write-Host "Install the following manually if not yet available:"
Write-Host "  - Nerd Font : JetBrainsMono Nerd Font (https://www.nerdfonts.com)"
Write-Host "  - Rustup    : https://rustup.rs"
Write-Host "  - .NET SDK  : https://dotnet.microsoft.com/download"
Write-Host "  - uv        : pwsh -ExecutionPolicy ByPass -c `"irm https://astral.sh/uv/install.ps1 | iex`""
Write-Host ""
Write-Host "Next: pwsh -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1"
