-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- spell はコードバッファでは無効(typos_lsp / harper_ls と三重に出てノイズになるため)。
-- prose 系 filetype のみで有効化する処理は autocmds.lua を参照。
vim.opt.spell = false
vim.opt.spelllang = { "en", "cjk" }
vim.opt.wrap = true

-- explorer / picker の root 検出。LazyVim のデフォルト { "lsp", { ".git", "lua" }, "cwd" } は
-- lsp を最優先するため、LSP の root_dir がサブディレクトリ(monorepo のパッケージ、
-- tsconfig.json や .csproj のあるディレクトリ)だとそこが explorer の root になってしまう。
-- 常に .git のあるリポジトリルートを root にする。
vim.g.root_spec = { ".git", "cwd" }
