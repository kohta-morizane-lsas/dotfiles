return {
	"nvim-telescope/telescope.nvim",
	opts = {
		defaults = {
			-- ripgrepを使う場合にgitignoreを無視
		},
		pickers = {
			find_files = {
				no_ignore = true, -- .gitignoreを無視
				hidden = true, -- 隠しファイルも表示
			},
		},
	},
}
