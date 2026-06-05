return {
  {
    "sindrets/diffview.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
      "DiffviewLog",
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview Open" },
      { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Diffview Close" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "Diffview File History (current file)" },
      { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview File History (repo)" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
}
