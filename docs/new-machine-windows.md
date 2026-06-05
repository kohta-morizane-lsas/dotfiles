# New Machine Setup (Windows)

Windows ネイティブ側 (PowerShell 7 / WezTerm / Neovim / Starship) のセットアップ手順。
WSL 側は [new-machine.md](new-machine.md) を参照。

## 0. 前提

### Developer Mode を有効化(シンボリックリンク作成に必要)

設定 → システム → 開発者向け → **開発者モード** を ON。

(有効化しない場合は、手順 4 を管理者 PowerShell で実行する)

### リポジトリは必ず `git clone` で取得する

ZIP ダウンロードは展開した全ファイルに Mark of the Web (Zone.Identifier) が付き、
プロファイルが「デジタル署名されていません」エラーでブロックされる原因になる。
`install-windows.ps1` が `Unblock-File` で無害化するが、最初から clone するのが確実。

## 1. WSL 2 + Ubuntu(未導入なら)

管理者 PowerShell で:

```powershell
wsl --install -d Ubuntu
```

再起動後、Ubuntu の初期設定を完了する。WSL 側のセットアップは [new-machine.md](new-machine.md) へ。

## 2. リポジトリのクローン

Git 未導入なら先に `winget install --id Git.Git -e` を実行してから:

```powershell
git clone git@github.com:YOUR_USERNAME/dotfiles.git $env:USERPROFILE\dotfiles
cd $env:USERPROFILE\dotfiles
```

> SSH 鍵が未設定なら HTTPS で clone してもよい。
> WSL 側のクローンとは独立しており、git push/pull で同期する。

## 3. パッケージ一括インストール

**初回は Windows PowerShell(`powershell`)で実行する** — 新規マシンには pwsh
(PowerShell 7) がまだ存在せず、このスクリプト自身が winget で導入するため:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows-packages.ps1
```

winget で導入されるもの: PowerShell 7, Git, gh, WezTerm, Neovim, Lazygit, Starship,
ripgrep, fd, fzf, eza, bat, zoxide, fnm
(加えて PSGallery から PSFzf — fzf の Ctrl+T / Ctrl+R キーバインド用)

手動で導入するもの:

- **Nerd Font**: JetBrainsMono Nerd Font (https://www.nerdfonts.com)
- **Rustup**: https://rustup.rs
- **.NET SDK**: https://dotnet.microsoft.com/download
- **uv**: `pwsh -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"`

## 4. 設定ファイルの配置(シンボリックリンク)

**PowerShell 7 (pwsh) で実行する**(初回は ExecutionPolicy 設定前なので Bypass 指定):

```powershell
pwsh -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1
```

実行内容:

| 処理 | 内容 |
| --- | --- |
| ExecutionPolicy | `Restricted` なら `RemoteSigned` (CurrentUser) に変更 — 以後 Bypass 指定は不要 |
| Unblock-File | リポジトリ内 `.ps1` の Mark of the Web を除去 |
| リンク作成 | 下表のとおり(既存ファイルは `.bak-<日時>` に退避) |
| local 設定 | `profile.local.ps1` / `.gitconfig.local` が無ければ example からコピー |
| bat テーマ | `bat cache --build` を実行してリンクしたテーマを反映 |

| リポジトリ | リンク先 |
| --- | --- |
| `wezterm/.wezterm.lua` | `%USERPROFILE%\.wezterm.lua` |
| `powershell/Microsoft.PowerShell_profile.ps1` | `$PROFILE` (`Documents\PowerShell\...`) |
| `starship/.config/starship.toml` | `%USERPROFILE%\.config\starship.toml` |
| `nvim/.config/nvim/` | `%LOCALAPPDATA%\nvim` |
| `nvim/.markdownlint-cli2.yaml` | `%USERPROFILE%\.markdownlint-cli2.yaml` |
| `lazygit/.config/lazygit/config.yml` | `%LOCALAPPDATA%\lazygit\config.yml` |
| `git/.gitconfig` | `%USERPROFILE%\.gitconfig` |
| `git/.gitignore_global` | `%USERPROFILE%\.gitignore_global` |
| `bat/.config/bat/themes/tokyonight_storm.tmTheme` | `%APPDATA%\bat\themes\tokyonight_storm.tmTheme` |

オプション: `-DryRun`(変更せず表示のみ)/ `-Uninstall`(リンク削除)

## 5. Machine-local 設定

`Documents\PowerShell\profile.local.ps1` を編集(git 管理外):

- `wslhome` 関数の WSL ユーザー名
- PowerToys CommandNotFound モジュール
- マシン固有のツールエイリアス

## 6. 言語ランタイム

```powershell
# Node (fnm)
fnm install --lts
fnm default lts-latest
npm install -g pnpm

# Rust (rustup-init.exe 実行後)
rustup component add rust-analyzer clippy rustfmt

# Python ツール
uv tool install ruff
```

## 7. Git identity

`.gitconfig` はリポジトリからリンクされ、`~/.gitconfig.local`(git 管理外)を
include する。identity は local 側に書く(WSL と同じ方式):

```powershell
git config -f $HOME\.gitconfig.local user.name  'Your Name'
git config -f $HOME\.gitconfig.local user.email 'you@example.com'
```

## 8. 動作確認チェックリスト

- [ ] WezTerm が起動し、`Ctrl-a u` で WSL タブ / `Ctrl-a Shift-N` で PowerShell タブが開く
- [ ] pwsh 起動時にエラーなく Starship プロンプトが表示される(署名エラーが出ないこと)
- [ ] `ls`, `ll`, `cat`, `grep`, `g`, `v` が動く
- [ ] `fo` でファイルが nvim で開く(WSL 側と同じ挙動)/ `Ctrl+T` で fzf が起動する
- [ ] `lazygit` のテーマ(Tokyo Night)が WSL 側と同じ見た目
- [ ] `git config user.name` が表示される(`.gitconfig.local` の値)
- [ ] Nerd Font のアイコンが崩れない
- [ ] `nvim` で `:LazyHealth` が概ね通る(初回はプラグイン自動ダウンロード)
- [ ] `fnm list` で Node バージョンが表示される
