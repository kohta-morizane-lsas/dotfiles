return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        basedpyright = {},
        -- ruff は uv でインストール済み(PATH)を nvim-lint/conform から使う。
        -- mason(pip)経由のインストール失敗ループを避けるため LSP は無効化。
        ruff = { enabled = false },
        -- Angular: テンプレート型チェック・コンポーネント補完(vtsls 単体では不可)。
        angularls = {},
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "angular" } },
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
        -- フォーマットは prettier に一本化(markdownlint と整形が衝突するため)。
        -- markdownlint-cli2 は下の nvim-lint 側で「診断のみ」担当させる。
        markdown = { "prettier" },
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
        -- markdown を lint 対象に追加。これで下の prepend_args(--config)が初めて効く。
        markdown = { "markdownlint-cli2" },
      },
      linters = {
        ["markdownlint-cli2"] = {
          prepend_args = { "--config", vim.fn.expand("~/.markdownlint-cli2.yaml") },
        },
      },
    },
  },
}
