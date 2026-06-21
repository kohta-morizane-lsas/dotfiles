# macOS 対応 + 環境リセット&再構築 設計書

- 日付: 2026-06-21
- 対象リポジトリ: `dotfiles`（現状 WSL Ubuntu + Windows/PowerShell 7 をサポート）
- ブランチ: `feat/support-mac-os`

## 1. 背景と目的

このセッションは Apple Silicon の macOS 上で実行されている。目的は2つ:

1. **dotfiles リポジトリを macOS にも対応させる**（現状 macOS は `bootstrap.sh` に
   最小限のブランチがあるのみで、シェル設定・ドキュメント・パッケージ管理は未対応）。
2. **現在の macOS の「開発環境」をリセットし、整備した dotfiles に従って再構築する**
   ための詳細な移行計画を立てる。

「リセット」の範囲は **開発環境のみ**（OS 初期化はしない）。Homebrew・CLI ツール・
dotfiles のシンボリックリンクなどをクリーンにしてから dotfiles で再構築する。

## 2. スコープ決定（確定事項）

| 論点 | 決定 |
| --- | --- |
| リセット範囲 | 開発環境のみ（macOS 本体は保持、再インストールしない） |
| ログインシェル | **zsh に移植**（macOS デフォルト、現在のシェルも zsh） |
| パッケージ管理 | **CLI ツール + フォントのみ** を `Brewfile` で管理（GUI アプリは手動インストール） |
| 共通ロジック共有 | bash/zsh 共通の **`shell/common.sh` に集約**し、両 rc から source |
| machine-specific 記述 | tracked file から `*.local` へ退避（リポジトリ規約に準拠） |

## 3. 現状の棚卸し（移行計画の前提）

このマシンの確認済み状態:

- `SHELL=/bin/zsh`（Apple 標準 zsh）
- Homebrew 6.0.2 が `/opt/homebrew`（Apple Silicon）に**インストール済み** → 撤去せず再利用する
- `~/.bashrc` / `~/.zshrc` / `~/.gitconfig` / `~/.config/nvim` は**いずれも実ファイル**
  （dotfiles のシンボリックリンクではない）→ バックアップ対象
- `~/.gitconfig.local` / `~/.config/starship.toml` / `~/.config/lazygit/config.yml` /
  `~/.markdownlint-cli2.yaml` は未配置

## 4. 現状リポジトリで判明している macOS 非対応箇所

- `bash/.bashrc` 末尾（L198-208）に machine-specific かつ Linux/WSL 専用の記述が
  **tracked file にコミットされている**:
  - `. "$HOME/.local/bin/env"`（存在ガードなし）
  - `export PATH=/usr/local/cuda/bin:$PATH` / `LD_LIBRARY_PATH=...`（CUDA、Linux 専用）
  - `source <(ng completion script)`（`ng` 未インストールだとエラー）
  - `code() { ".../Microsoft VS Code/bin/code" --remote wsl+Ubuntu ... }`（WSL パス固定）
  - これらはリポジトリ規約「Never put machine-specific values in tracked files」に違反。
- `bash/.bashrc` L83 の `xargs -d '\n'` は GNU 専用。BSD/macOS の `xargs` には `-d` が無い。
- macOS デフォルトの zsh 用設定（`.zshrc`）が存在しない。
- `wezterm/.wezterm.lua` は Windows 専用（`pwsh.exe` / `USERPROFILE`）。**本対応では扱わない**
  （GUI アプリは手動スコープのため）。
- README / docs に macOS 手順が無い。
- `.stow-local-ignore` は既に `Brewfile` を ignore 対象として記載済み（Brewfile 導入を想定済み）。

## 5. 設計詳細

### A. dotfiles の macOS 対応（リポジトリ変更）

#### A-1. 共通シェルロジックの抽出 — 新規 `shell` パッケージ

新規ファイル `shell/.config/shell/common.sh`（POSIX sh 互換で記述、bash と zsh の両方から source）。
ここに以下を集約する:

- 環境変数: `EDITOR` / `VISUAL` / `BAT_THEME`
- ツール名解決: `FD_BIN`（`fd` か `fdfind`）/ `BAT_BIN`（`bat` か `batcat`）
- fzf 用: `FZF_DEFAULT_COMMAND` / `FZF_CTRL_T_COMMAND` / `FZF_ALT_C_COMMAND`
- 全 alias（`ls`/`ll`/`la`/`lt`/`lrt`/`cat`/`grep`/`ff`/`g`/`v`）
- 全関数: `fo` / `fc` / `fom` / `frg` / `fcd` / `ij` / `ijeod`

**ポータビリティ修正**:
- `fom` 内の `xargs -d '\n' nvim` は GNU 専用 → bash/zsh かつ GNU/BSD 両対応の形へ。
  方針: `fd ... -0`（NUL 区切り出力）にして `xargs -0 nvim` を使う。
  fzf も `--read0 --print0` を用い、NUL 区切りで一貫させる（ファイル名に改行が含まれても安全）。
- 関数内 `local` は bash/zsh の両方で関数スコープ変数として有効。`case`/`shift` も両対応。
- `common.sh` には **シェル固有の `eval "$(... init bash)"` 系を含めない**（各 rc に置く）。

`bash/.bashrc`（既存を整理）:
- 共通部分（上記）を削除し `[ -f "$HOME/.config/shell/common.sh" ] && . "$HOME/.config/shell/common.sh"` を追加。
- bash 固有の初期化のみ残す:
  - `fzf --bash`（フォールバック付き）/ `zoxide init bash` / `starship init bash`
  - `fnm env --use-on-cd --shell bash`
  - Rust `~/.cargo/env` の読み込み
  - `[ -f "$HOME/.bashrc.local" ] && . "$HOME/.bashrc.local"`
- **末尾 L198-208 の machine-specific 記述を削除**し、`.bashrc.local` へ移すべき例として
  `bash/.bashrc.local.example` にコメント付きで追記する（uv env / CUDA / ng completion /
  WSL `code()`）。
- この変更は WSL 環境にも反映される。**挙動が変わらないこと**（同じ alias/関数/環境変数が
  同じ結果になること）を移植の絶対条件とする。

`zsh/.zshrc`（新規）:
- zsh 固有の初期化:
  - 補完: `autoload -Uz compinit && compinit`
  - `fzf --zsh`（フォールバック不要、Homebrew fzf は新しい）
  - `zoxide init zsh` / `starship init zsh`
  - `fnm env --use-on-cd --shell zsh`
  - Rust `~/.cargo/env` の読み込み
- `[ -f "$HOME/.config/shell/common.sh" ] && . "$HOME/.config/shell/common.sh"`
- `[ -f "$HOME/.zshrc.local" ] && . "$HOME/.zshrc.local"`（machine-local 退避先）
- `*.local` は既に gitignore 済みか確認し、必要なら `.gitignore` に `.zshrc.local` を追加。
  併せて `zsh/.zshrc.local.example` を用意する。

#### A-2. `Brewfile`（新規、リポジトリ直下）

CLI ツール + フォントのみを管理:

```ruby
# CLI tools
brew "stow"
brew "git"
brew "ripgrep"
brew "fd"
brew "fzf"
brew "bat"
brew "eza"
brew "zoxide"
brew "neovim"
brew "lazygit"
brew "starship"
brew "gh"

# Fonts (Nerd Font for terminal/nvim icons)
cask "font-jetbrains-mono-nerd-font"
```

- `bootstrap.sh` の `install_macos()` を `brew bundle --file="$DOTFILES_DIR/Brewfile"` 方式へ置換。
  Homebrew 未導入時のインストールは現状ロジックを維持。
- フォントは cask だが「フォントのみ」スコープ内として許容（GUI アプリ cask は含めない）。

#### A-3. `install.sh`

- `ALL_PACKAGES` に `shell` と `zsh` を追加: `(bash zsh shell git starship lazygit nvim bat)`。
- stow はクロスプラットフォームに動作するため OS 分岐は導入しない。
  macOS でも bash パッケージを stow して問題ない（ログインは zsh だが bash 起動時に利用可能）。

#### A-4. `scripts/backup-existing.sh`

- `FILES_TO_BACKUP` に `~/.zshrc` を追加。
- `~/.config/shell/` ディレクトリ（非シンボリックリンク時）のバックアップ処理を追加
  （nvim ディレクトリと同様の扱い）。

#### A-5. ドキュメント

- 新規 `docs/new-machine-macos.md`: SSH 鍵 → clone →（Homebrew）→ `brew bundle` →
  `./install.sh --all` → 言語ランタイム（fnm / uv / rust）→ machine-local 設定 → 検証。
- `README.md`: macOS セクションを追加（Quick Start に macOS 手順、Packages 表に
  `shell` / `zsh` を追記、共有設定の説明を更新）。

### B. 環境リセット&再構築の移行手順

> 実行は別途。ここでは手順を定義する。各 Phase は破壊的操作の前に確認を挟む。

**Phase 0 — 棚卸し&バックアップ**
- `brew leaves > ~/brew-leaves-backup.txt`、`brew list --cask > ~/brew-casks-backup.txt` を記録。
- 既存 `~/.zshrc` / `~/.bashrc` / `~/.gitconfig` / `~/.config/nvim` 等を確認
  （`backup-existing.sh` が自動退避するが、内容に取り込みたい設定がないか目視確認）。
- `~/.gitconfig` から user.name / user.email を控える（machine-local に再投入するため）。

**Phase 1 — 既存開発環境の撤去**
- 既存の dotfiles シンボリックリンクがあれば `./install.sh --all --unstow`
  （今回は実ファイルのため該当なしの見込み）。
- Homebrew **本体は残す**。不要パッケージは任意で `brew bundle cleanup` 等で整理可能だが
  必須ではない（再構築は冪等）。

**Phase 2 — クリーン再構築**
1. `bash scripts/bootstrap.sh`（macOS 分岐で `brew bundle` 実行）
2. `./install.sh --all`（`backup-existing.sh` が既存実ファイルを退避してから stow）
3. ログインシェルの確認（既に zsh のため `chsh` 不要）。新しいシェルを開いて反映確認。
4. 言語ランタイム（必要なもののみ）:
   - Node: `curl -fsSL https://fnm.vercel.app/install | bash`
   - Python: `curl -LsSf https://astral.sh/uv/install.sh | sh`
   - Rust: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
5. machine-local 設定:
   - `git config -f ~/.gitconfig.local user.name '...'` / `user.email '...'`
   - 必要なら `~/.zshrc.local`（macOS 固有 PATH 等）を作成。

**Phase 3 — 検証**
- シェル関数: `fo` / `fc` / `fom` / `frg` / `fcd` が動作する。
- alias: `ls`（eza）/ `cat`（bat）/ `g`（lazygit）/ `v`（nvim）。
- プロンプト/補助: starship 表示、`z`（zoxide）、`Ctrl+T` / `Ctrl+R`（fzf）。
- nvim: 起動でプラグイン取得 → `:LazyHealth` がクリーン。
- `git config --get user.email` が machine-local の値を返す。

## 6. テスト戦略

- **macOS 実機での手動検証**（Phase 3 のチェックリスト）。
- **bash 後方互換の確認**: 共通化後の `common.sh` を bash で source し、移植前と同じ
  alias/関数/環境変数になることを確認（WSL リグレッション防止）。可能なら Linux/WSL でも
  `source ~/.bashrc` がエラーなく通ることを確認。
- **`brew bundle` のドライ実行**: `brew bundle check --file=Brewfile` で記述ミスを検出。
- **stow ドライラン**: `./install.sh --all --dry-run` でリンク先衝突を事前確認。

## 7. 影響範囲とリスク

- `bash/.bashrc` の整理は WSL 環境にも波及する。挙動同一を移植の絶対条件とし、
  machine-specific 記述の退避は `.bashrc.local.example` への移設で代替（既存 WSL マシンでは
  ユーザーが `~/.bashrc.local` に反映する必要がある旨をドキュメント化）。
- `xargs -d` → NUL 区切りへの変更で `fom` の挙動が変わらないこと（複数選択 → nvim 一括起動）
  を確認する。
- Homebrew 本体は残すため、既存の他用途パッケージへの破壊的影響はない。

## 8. 非対象（YAGNI）

- macOS GUI アプリの cask 管理（WezTerm / VS Code / ブラウザ等）— 手動。
- `wezterm/.wezterm.lua` の macOS 対応 — 今回は触らない。
- macOS システム環境設定（`defaults write` 等）の自動化。
- OS の初期化・再インストール。
