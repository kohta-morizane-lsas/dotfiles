return {
  {
    "mikavilpas/yazi.nvim",
    version = "*", -- 最新の安定タグを使う
    event = "VeryLazy",
    dependencies = {
      { "nvim-lua/plenary.nvim", lazy = true },
    },
    keys = {
      { "<leader>y", "", desc = "+yazi" },
      { "<leader>yy", "<cmd>Yazi<cr>", mode = { "n", "v" }, desc = "Yazi (current file)" },
      { "<leader>yc", "<cmd>Yazi cwd<cr>", desc = "Yazi (cwd)" },
      { "<leader>yr", "<cmd>Yazi toggle<cr>", desc = "Yazi resume last session" },
    },
    ---@type YaziConfig | {}
    opts = {
      -- netrw / ディレクトリ表示は snacks explorer (<leader>e) に任せるので false。
      open_for_directories = false,
      -- 表示中の split と quickfix を yazi のタブとして開く。
      open_multiple_tabs = true,
      keymaps = {
        show_help = "<f1>",
      },
      -- 既定は telescope だが未導入。LazyVim 既定の snacks.picker に合わせる。
      integrations = {
        grep_in_directory = "snacks.picker",
        grep_in_selected_files = "snacks.picker",
      },
    },
  },
  {
    -- <leader><leader> は LazyVim の snacks_picker extra が
    -- "Find Files (Root Dir)" (= <leader>ff と同じ) を割り当てている。
    -- 同じ lhs を snacks.nvim の spec 側で再定義して yazi に差し替える。
    -- ファジーなファイル検索は <leader>ff に残る。
    "folke/snacks.nvim",
    keys = {
      {
        "<leader><leader>",
        -- :Yazi はパス引数を取れないので Lua API を使う。LazyVim.root() は
        -- config/options.lua の vim.g.root_spec = { ".git", "cwd" } に従うので
        -- git リポジトリのルート(なければ cwd)が開く。
        function()
          require("yazi").yazi(nil, LazyVim.root())
        end,
        mode = { "n", "v" },
        desc = "Yazi (repo root)",
      },
    },
  },
}
