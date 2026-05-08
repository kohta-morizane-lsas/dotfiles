# Remove built-in aliases so our functions take precedence
Remove-Alias ls  -Force -ErrorAction SilentlyContinue
Remove-Alias cat -Force -ErrorAction SilentlyContinue

# UTF-8 encoding (fd/fzf などの日本語ファイル名対策)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

# fzf のデフォルト検索コマンド (Ctrl+T などの組み込みキーバインドにも適用)
$env:FZF_DEFAULT_COMMAND = 'fd --type f --hidden --exclude .git'
$env:FZF_CTRL_T_COMMAND  = $env:FZF_DEFAULT_COMMAND
$env:FZF_ALT_C_COMMAND   = 'fd --type d --hidden --exclude .git'

# Common Unix-like commands
function ls   { eza --group-directories-first --icons @args }
function ll   { eza -l --group-directories-first --icons --git @args }
function la   { eza -la --group-directories-first --icons --git @args }
function lt   { eza --tree --icons @args }
function lrt  { eza -l --group-directories-first --icons --git @args --sort=newest}
function cat  { bat @args }
function grep { rg @args }
function ff   { fd @args }
function g    { lazygit }
function v    { nvim }
function wslhome {
  cd "\\wsl.localhost\Ubuntu\home\kohta"
}
function q { exit }

# fzf + fd で検索してファイルを開く
function fo {
    param(
        [string]$Path = ".",
        [string]$Pattern = ""
    )
    $file = fd --type f --hidden --exclude .git --absolute-path $Pattern $Path | fzf
    if ($file) { Start-Process -FilePath $file }
}

# 拡張子別ショートカット
function fop  { $f = fd --type f --hidden --exclude .git --absolute-path -e pptx | fzf; if ($f) { Start-Process $f } }
function fox  { $f = fd --type f --hidden --exclude .git --absolute-path -e xlsx | fzf; if ($f) { Start-Process $f } }
function fod  { $f = fd --type f --hidden --exclude .git --absolute-path -e docx | fzf; if ($f) { Start-Process $f } }
function fopd { $f = fd --type f --hidden --exclude .git --absolute-path -e pdf  | fzf; if ($f) { Start-Process $f } }

# 複数選択して一括で開く (Tab で選択)
function fom {
    fd --type f --hidden --exclude .git --absolute-path | fzf -m | ForEach-Object { Start-Process $_ }
}

# ディレクトリ選択して cd (zoxide と併用可)
function fcd {
    param(
        [string]$Path = ".",
        [string]$Pattern = ""
    )
    $dir = fd --type d --hidden --exclude .git --absolute-path $Pattern $Path | fzf
    if ($dir) { Set-Location -LiteralPath $dir }
}

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

Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })
Invoke-Expression (& { (fnm env --use-on-cd --shell power-shell | Out-String) })

#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58

. "C:\Users\Kohta-Morizane\tools\powershell-profile\tools-aliases.ps1"
