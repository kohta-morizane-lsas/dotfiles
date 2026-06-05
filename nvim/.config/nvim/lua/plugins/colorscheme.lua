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
	{
		"shaunsingh/nord.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		lazy = false,
		priority = 1000,
		opts = {
			flavour = "mocha", -- latte, frappe, macchiato, mocha
		},
	},
	{
		"xiyaowong/transparent.nvim",
	},
	{
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "tokyonight-night",
		},
	},
}
