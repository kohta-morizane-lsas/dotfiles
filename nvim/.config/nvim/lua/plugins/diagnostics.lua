return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        -- virtual_text は行末 1 行に押し込まれるため、tsserver の長い型エラーが
        -- 画面右端で見切れる。カーソル行だけ virtual_lines(コード行の下に
        -- 折り返して展開)にして全文を読めるようにする。
        virtual_text = false,
        virtual_lines = { current_line = true },
      },
    },
  },
}
