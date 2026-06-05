# Deploy dotfiles on Windows via symbolic links (Windows counterpart of install.sh).
# First run (before execution policy is configured):
#   pwsh -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1
#
# Requires symlink permission: enable Developer Mode
# (Settings > System > For developers) or run from an elevated shell.
#
#   -DryRun     Show what would happen without making changes
#   -Uninstall  Remove symlinks created by this script

param(
  [switch]$DryRun,
  [switch]$Uninstall
)

$ErrorActionPreference = "Stop"

if ($PSVersionTable.PSEdition -ne "Core") {
  Write-Error "Run this script with PowerShell 7 (pwsh), not Windows PowerShell. `$PROFILE would point to the wrong location."
  exit 1
}

$RepoRoot = Split-Path -Parent $PSScriptRoot
$ProfileDir = Split-Path -Parent $PROFILE

# --- 1. Execution policy: allow local scripts and the (linked) profile to load ---
$policy = Get-ExecutionPolicy
if ($policy -in @("Restricted", "AllSigned", "Undefined")) {
  if ($DryRun) {
    Write-Host "[dry-run] Set-ExecutionPolicy RemoteSigned -Scope CurrentUser (current: $policy)"
  } else {
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Write-Host "Execution policy set to RemoteSigned (CurrentUser)."
  }
}

# --- 2. Remove Mark of the Web from repo scripts (avoids 'not digitally signed' errors
#        when the repo was downloaded as a ZIP instead of git-cloned) ---
if (-not $DryRun) {
  Get-ChildItem -Path $RepoRoot -Recurse -Include *.ps1, *.psm1, *.psd1 | Unblock-File
}

# --- 3. Verify symlink permission before touching anything ---
if (-not $DryRun -and -not $Uninstall) {
  $testLink = Join-Path $env:TEMP "dotfiles-symlink-test"
  try {
    New-Item -ItemType SymbolicLink -Path $testLink -Target $RepoRoot -Force | Out-Null
    Remove-Item $testLink -Force
  } catch {
    Write-Error @"
Cannot create symbolic links. Either:
  - Enable Developer Mode: Settings > System > For developers > Developer Mode
  - Or run this script from an elevated (administrator) shell
"@
    exit 1
  }
}

# --- 4. Link map: repo file -> deployed location ---
$links = @(
  @{ Source = Join-Path $RepoRoot "wezterm\.wezterm.lua"
     Target = Join-Path $HOME ".wezterm.lua" },
  @{ Source = Join-Path $RepoRoot "powershell\Microsoft.PowerShell_profile.ps1"
     Target = $PROFILE },
  @{ Source = Join-Path $RepoRoot "starship\.config\starship.toml"
     Target = Join-Path $HOME ".config\starship.toml" },
  @{ Source = Join-Path $RepoRoot "nvim\.config\nvim"
     Target = Join-Path $env:LOCALAPPDATA "nvim" }
)

function Get-LinkTarget([string]$Path) {
  $item = Get-Item $Path -Force -ErrorAction SilentlyContinue
  if ($item -and $item.LinkType -eq "SymbolicLink") { return $item.Target }
  return $null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

foreach ($link in $links) {
  $source = $link.Source
  $target = $link.Target

  if ($Uninstall) {
    if ((Get-LinkTarget $target) -eq $source) {
      if ($DryRun) { Write-Host "[dry-run] remove link $target" }
      else {
        Remove-Item $target -Force -Recurse:$false
        Write-Host "Removed link: $target"
      }
    } else {
      Write-Host "Skip (not a link to this repo): $target"
    }
    continue
  }

  if (-not (Test-Path $source)) {
    Write-Warning "Source missing, skipped: $source"
    continue
  }

  if ((Get-LinkTarget $target) -eq $source) {
    Write-Host "Already linked: $target"
    continue
  }

  if ($DryRun) {
    Write-Host "[dry-run] link $target -> $source"
    continue
  }

  $parent = Split-Path -Parent $target
  if (-not (Test-Path $parent)) {
    New-Item -ItemType Directory -Path $parent -Force | Out-Null
  }

  if (Test-Path $target) {
    $backup = "$target.bak-$timestamp"
    Move-Item $target $backup -Force
    Write-Host "Backed up: $target -> $backup"
  }

  New-Item -ItemType SymbolicLink -Path $target -Target $source -Force | Out-Null
  Write-Host "Linked: $target -> $source"
}

# --- 5. Seed profile.local.ps1 from example if missing (machine-local, untracked) ---
$localProfile = Join-Path $ProfileDir "profile.local.ps1"
if (-not $Uninstall -and -not (Test-Path $localProfile)) {
  if ($DryRun) {
    Write-Host "[dry-run] copy profile.local.ps1.example -> $localProfile"
  } else {
    Copy-Item (Join-Path $RepoRoot "powershell\profile.local.ps1.example") $localProfile
    Write-Host "Created $localProfile from example - edit it for this machine."
  }
}

Write-Host ""
Write-Host "Done."
