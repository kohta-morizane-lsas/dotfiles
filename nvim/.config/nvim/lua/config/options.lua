-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- spell はコードバッファでは無効(typos_lsp / harper_ls と三重に出てノイズになるため)。
-- prose 系 filetype のみで有効化する処理は autocmds.lua を参照。
vim.opt.spell = false
vim.opt.spelllang = { "en", "cjk" }
vim.opt.wrap = true
