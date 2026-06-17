return {
	{
		"folke/tokyonight.nvim",
		opts = {
			style = "night",
			transparent = false,
			styles = {
				sidebars = "dark",
				floats = "dark",
			},
		},
	},
	-- 予備テーマ。アクティブは tokyonight-night なので遅延ロード(起動時に常駐させない)。
	-- :colorscheme で切り替えた瞬間に読み込まれる。
	{
		"shaunsingh/nord.nvim",
		lazy = true,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = true,
		opts = {
			flavour = "mocha", -- latte, frappe, macchiato, mocha
		},
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "tokyonight-night",
		},
	},
}
