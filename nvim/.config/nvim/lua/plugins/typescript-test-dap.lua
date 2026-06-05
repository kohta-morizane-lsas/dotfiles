return {
  { "nvim-neotest/neotest-jest", ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" } },
  { "marilari88/neotest-vitest", ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" } },
  {
    "microsoft/vscode-js-debug",
    build = function(plugin)
      vim.fn.system({ "npm", "install", "--legacy-peer-deps" })
      vim.fn.system({ "npx", "gulp", "vsDebugServerBundle" })
      vim.fn.rename(plugin.dir .. "/dist", plugin.dir .. "/out")
    end,
  },
  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = { "mfussenegger/nvim-dap", "microsoft/vscode-js-debug" },
    config = function()
      require("dap-vscode-js").setup({
        debugger_path = vim.fn.stdpath("data") .. "/lazy/vscode-js-debug",
        adapters = { "pwa-node" },
      })
    end,
  },
  {
    "nvim-neotest/neotest",
    opts = function(_, opts)
      table.insert(opts.adapters, require("neotest-jest")({
        jestCommand = "pnpm test --",
        jestConfigFile = "jest.config.ts",
        env = { CI = true },
      }))
      table.insert(opts.adapters, require("neotest-vitest")({
        filter_dir = function(name)
          return name ~= "node_modules"
        end,
      }))
    end,
  },
  {
    "mfussenegger/nvim-dap",
    opts = function()
      local dap = require("dap")
      for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch current file",
            program = "${file}",
            cwd = "${workspaceFolder}",
            sourceMaps = true,
            protocol = "inspector",
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Jest current file",
            runtimeExecutable = "node",
            runtimeArgs = {
              "./node_modules/jest/bin/jest.js",
              "--runInBand",
              "${file}",
            },
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug Vitest current file",
            runtimeExecutable = "node",
            runtimeArgs = {
              "./node_modules/vitest/vitest.mjs",
              "run",
              "${file}",
            },
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
          },
        }
      end
    end,
  },
}
