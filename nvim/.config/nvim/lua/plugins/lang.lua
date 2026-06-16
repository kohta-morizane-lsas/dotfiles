return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {},
        -- ruff は uv でインストール済み(PATH)を nvim-lint/conform から使う。
        -- mason(pip)経由のインストール失敗ループを避けるため LSP は無効化。
        ruff = { enabled = false },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier", "markdownlint-cli2" },
        python = { "ruff_fix", "ruff_format" },
        rust = { "rustfmt" },
        cs = { "csharpier" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        -- JS/TS の eslint 診断は eslint-lsp(LSP) で取得するため nvim-lint からは外す。
        python = { "ruff" },
        rust = { "clippy" },
      },
      linters = {
        ["markdownlint-cli2"] = {
          prepend_args = { "--config", vim.fn.expand("~/.markdownlint-cli2.yaml") },
        },
      },
    },
  },
}
