return {
  { "nvim-neotest/neotest-python", ft = "python" },
  { "mfussenegger/nvim-dap-python", ft = "python" },
  {
    "nvim-neotest/neotest",
    opts = function(_, opts)
      table.insert(opts.adapters, require("neotest-python")({
        dap = { justMyCode = true },
        runner = "pytest",
        python = function()
          return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
        end,
      }))
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      local python = vim.fn.exepath("python3")
      if python == "" then
        python = "python"
      end
      require("dap-python").setup(python)
    end,
  },
}
