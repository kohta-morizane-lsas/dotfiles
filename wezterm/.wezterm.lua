local wezterm = require("wezterm")
local act = wezterm.action

local config = {}

config.default_prog = { "pwsh.exe", "-NoLogo" }
config.default_cwd = os.getenv("USERPROFILE")
config.color_scheme = "Tokyo Night Storm"
config.font = wezterm.font_with_fallback({
	{ family = "JetBrainsMono Nerd Font", weight = "Medium" },
	"Noto Color Emoji",
})
config.font_size = 12.5
config.line_height = 1.05
config.cell_width = 1.0
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.adjust_window_size_when_changing_font_size = false
config.window_decorations = "RESIZE"
config.window_padding = {
	left = 8,
	right = 8,
	top = 8,
	bottom = 8,
}
config.command_palette_bg_color = "#1a1b26"
config.command_palette_fg_color = "#c0caf5"
config.window_background_opacity = 0.8
-- config.win32_system_backdrop = 'Acrylic'
config.front_end = 'OpenGL'
config.prefer_egl = true
config.scrollback_lines = 10000
config.enable_scroll_bar = false
config.warn_about_missing_glyphs = false
config.tab_max_width = 32

-- config.enable_kitty_graphics = true
-- config.enable_bracketed_paste = true

config.wsl_domains = wezterm.default_wsl_domains()
config.default_domain = "local"

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- Pane split
	{ key = "-", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "\\", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

	-- Pane navigation
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- Pane resize
	{ key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 4 }) },
	{ key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 2 }) },
	{ key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 2 }) },
	{ key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 4 }) },

	-- Pane zoom / close
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },

	-- Tabs
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{ key = "1", mods = "LEADER", action = act.ActivateTab(0) },
	{ key = "2", mods = "LEADER", action = act.ActivateTab(1) },
	{ key = "3", mods = "LEADER", action = act.ActivateTab(2) },
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Rename current tab",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- Launcher / palette
	{ key = "w", mods = "LEADER", action = act.ShowLauncher },
	{ key = "P", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette },

	-- Quick domain tabs
	{
		key = "u",
		mods = "LEADER",
		action = act.SpawnCommandInNewTab({ domain = { DomainName = "WSL:Ubuntu" } }),
	},
	{
		key = "N",
		mods = "LEADER|SHIFT",
		action = act.SpawnCommandInNewTab({
			domain = { DomainName = "local" },
			args = { "pwsh.exe", "-NoLogo" },
		}),
	},

	-- Send literal Ctrl-a
	{ key = "a", mods = "LEADER", action = act.SendKey({ key = "a", mods = "CTRL" }) },
}

config.launch_menu = {
	{ label = "PowerShell 7", args = { "pwsh.exe", "-NoLogo" } },
	{ label = "WSL Ubuntu", args = { "wsl.exe", "--distribution", "Ubuntu" } },
}

-- Git Bash: only offer it when the default install actually exists
local git_bash = "C:/Program Files/Git/bin/bash.exe"
local git_bash_handle = io.open(git_bash, "r")
if git_bash_handle then
	git_bash_handle:close()
	table.insert(config.launch_menu, 2, { label = "Git Bash", args = { git_bash, "-l" } })
end

return config
