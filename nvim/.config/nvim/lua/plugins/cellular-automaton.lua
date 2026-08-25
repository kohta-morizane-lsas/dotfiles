-- ネタプラグイン。現在のバッファを崩して遊ぶだけで、編集内容には影響しない。
return {
  {
    "Eandrju/cellular-automaton.nvim",
    cmd = "CellularAutomaton",
    keys = {
      { "<leader>fml", "<cmd>CellularAutomaton make_it_rain<cr>", desc = "Cellular Automaton: make it rain" },
      { "<leader>fmg", "<cmd>CellularAutomaton game_of_life<cr>", desc = "Cellular Automaton: game of life" },
      { "<leader>fms", "<cmd>CellularAutomaton scramble<cr>", desc = "Cellular Automaton: scramble" },
    },
  },
}
