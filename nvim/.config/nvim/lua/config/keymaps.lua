-- LazyVim 既定に統一。重複・衝突する keymap は削除し、真に独自のものだけ残す。
-- 既定で提供される keymap:
--   ウィンドウ移動  <C-hjkl>
--   ファイル/検索   <leader>e / ff / fg / fr / xx
--   テスト(neotest) <leader>tt(file) / tr(nearest) / ts / to / td(debug) ...
--   デバッグ(dap)   <leader>db / dc / di / do(step out) / dO(step over) / dr / du ...
local map = vim.keymap.set

-- ターミナルポップアップ(cwd)
map("n", "<leader>tp", function()
	Snacks.terminal()
end, { desc = "Terminal popup" })

-- jj で挿入モード脱出
map("i", "jj", "<Esc>", { desc = "Escape insert mode" })
