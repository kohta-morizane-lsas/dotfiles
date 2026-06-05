# Remove built-in aliases so our functions take precedence
Remove-Alias ls  -Force -ErrorAction SilentlyContinue
Remove-Alias cat -Force -ErrorAction SilentlyContinue
Remove-Alias fc  -Force -ErrorAction SilentlyContinue  # Format-Custom — shadows our fc function

# UTF-8 encoding (fd/fzf などの日本語ファイル名対策)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# bat theme (bash 側の BAT_THEME と同じ — bat cache --build 済みであること)
$env:BAT_THEME = 'tokyonight_storm'

# fzf のデフォルト検索コマンド (Ctrl+T などの組み込みキーバインドにも適用)
$env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git'
$env:FZF_CTRL_T_COMMAND  = $env:FZF_DEFAULT_COMMAND
$env:FZF_ALT_C_COMMAND   = 'fd --type d --hidden --exclude .git'

# fzf preview (bash 側と同じ見た目)
$FzfPreview = 'bat --style=numbers --color=always --line-range :100 {}'

# Common Unix-like commands
function ls   { eza --group-directories-first --icons @args }
function ll   { eza -l --group-directories-first --icons --git @args }
function la   { eza -la --group-directories-first --icons --git @args }
function lt   { eza --tree --icons @args }
function lrt  { eza -l --group-directories-first --icons --git --sort=newest @args }
function g    { lazygit @args }
function v    { nvim @args }
function ff   { fd @args }
function q    { exit }

# cat/grep — パイプライン入力にも対応 (history | grep ssh など)
function cat {
    if ($MyInvocation.ExpectingInput) { $input | bat @args } else { bat @args }
}
function grep {
    if ($MyInvocation.ExpectingInput) { $input | rg @args } else { rg @args }
}

# fzf + fd: ファイルを選んで nvim で開く (bash 側の fo と同じ挙動)
# Usage: fo [-H|-R] [path] [pattern]   -H: $HOME から検索 / -R: ドライブルートから検索
function fo {
    param(
        [switch]$H,
        [switch]$R,
        [string]$Path,
        [string]$Pattern = ""
    )
    if (-not $Path) { $Path = if ($H) { $HOME } elseif ($R) { "\" } else { "." } }
    $file = fd --type f --hidden --exclude .git $Pattern $Path | fzf --preview $FzfPreview
    if ($file) { nvim $file }
}

# fzf + fd: ファイルを選んで $VISUAL (未設定なら nvim) で開く
function fc {
    param(
        [string]$Path = ".",
        [string]$Pattern = ""
    )
    $file = fd --type f --hidden --exclude .git $Pattern $Path | fzf --preview $FzfPreview
    if ($file) {
        $editor = if ($env:VISUAL) { $env:VISUAL } else { "nvim" }
        & $editor $file
    }
}

# 複数選択して nvim で一括で開く (Tab で選択)
function fom {
    $files = fd --type f --hidden --exclude .git | fzf -m --preview $FzfPreview
    if ($files) { nvim @($files) }
}

# ripgrep → fzf: ファイル内容を検索して該当行に nvim でジャンプ
function frg {
    param([string]$Query = "")
    $result = rg --line-number --no-heading --color=always --smart-case --hidden --glob '!.git' $Query |
        fzf --ansi --delimiter : `
            --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' `
            --preview-window 'right,60%,+{2}/2'
    if ($result) {
        $file, $line, $null = $result -split ':', 3
        nvim "+$line" $file
    }
}

# ディレクトリ選択して cd (zoxide と併用可)
# Usage: fcd [-H|-R] [pattern] [path]
function fcd {
    param(
        [switch]$H,
        [switch]$R,
        [string]$Pattern = "",
        [string]$Path
    )
    if (-not $Path) { $Path = if ($H) { $HOME } elseif ($R) { "\" } else { "." } }
    $dir = fd --type d --hidden --exclude .git $Pattern $Path | fzf
    if ($dir) { Set-Location -LiteralPath $dir }
}

# --- Windows 専用ヘルパー (既定アプリ/Explorer で開く系) ---

# ファイルを選んで Windows の既定アプリで開く
function fos {
    param(
        [string]$Path = ".",
        [string]$Pattern = ""
    )
    $file = fd --type f --hidden --exclude .git --absolute-path $Pattern $Path | fzf
    if ($file) { Start-Process -FilePath $file }
}

# 複数選択して既定アプリで一括で開く (Tab で選択)
function fosm {
    fd --type f --hidden --exclude .git --absolute-path | fzf -m | ForEach-Object { Start-Process $_ }
}

# 拡張子別ショートカット
function fop  { $f = fd --type f --hidden --exclude .git --absolute-path -e pptx | fzf; if ($f) { Start-Process $f } }
function fox  { $f = fd --type f --hidden --exclude .git --absolute-path -e xlsx | fzf; if ($f) { Start-Process $f } }
function fod  { $f = fd --type f --hidden --exclude .git --absolute-path -e docx | fzf; if ($f) { Start-Process $f } }
function fopd { $f = fd --type f --hidden --exclude .git --absolute-path -e pdf  | fzf; if ($f) { Start-Process $f } }

# ディレクトリを選んで Explorer で開く
function fe {
    param(
        [string]$Path = ".",
        [string]$Pattern = ""
    )
    $dir = fd --type d --hidden --exclude .git --absolute-path $Pattern $Path | fzf
    if ($dir) { explorer.exe $dir }
}

# カレントまたは指定ディレクトリを Explorer で開く
function e {
    param([string]$Path = ".")
    explorer.exe (Resolve-Path -LiteralPath $Path).Path
}

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineKeyHandler -Key Ctrl+h -Function BackwardDeleteChar

# fzf キーバインド (Ctrl+T: ファイル / Ctrl+R: 履歴) — install-windows-packages.ps1 が PSFzf を導入
if (Get-Module -ListAvailable -Name PSFzf) {
    Import-Module PSFzf
    Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
}

Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Invoke-Expression (& { (fnm env --use-on-cd --shell power-shell | Out-String) })

# Machine-local settings (not tracked by git) — see profile.local.ps1.example
$localProfile = Join-Path (Split-Path -Parent $PROFILE) 'profile.local.ps1'
if (Test-Path $localProfile) { . $localProfile }
