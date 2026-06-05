return {
  { "Nsidorenco/neotest-vstest", ft = { "cs", "fsharp", "vb" } },
  {
    "nvim-neotest/neotest",
    opts = function(_, opts)
      table.insert(opts.adapters, require("neotest-vstest")({
        dap = { justMyCode = true },
      }))
    end,
  },
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")
      if not dap.adapters.netcoredbg then
        dap.adapters.netcoredbg = {
          type = "executable",
          command = vim.fn.exepath("netcoredbg"),
          args = { "--interpreter=vscode" },
          options = { detached = false },
        }
      end
      dap.configurations.cs = {
        {
          type = "netcoredbg",
          name = "Launch .NET project",
          request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopAtEntry = false,
        },
      }
    end,
  },
}
