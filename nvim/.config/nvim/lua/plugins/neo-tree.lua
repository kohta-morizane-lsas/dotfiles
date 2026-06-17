return {
	"nvim-neo-tree/neo-tree.nvim",
	opts = {
		filesystem = {
			filtered_items = {
				visible = true, -- gitignoreされたファイルを薄く表示
				hide_gitignored = false, -- gitignoreを無視して表示
			},
		},
	},
}
