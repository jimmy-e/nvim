return {
  -- Core DAP
  {
    "mfussenegger/nvim-dap",
  },

  -- UI panels (variables, stack, breakpoints, etc.)
  {
    "rcarriga/nvim-dap-ui",
    dependencies = {
      "mfussenegger/nvim-dap",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      -- Auto-open/close UI like VS Code
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },

  -- Python DAP (uses debugpy from your selected python)
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      local dap = require("dap")

      local function python_path()
        local venv = vim.fn.getcwd() .. "/.venv/bin/python"
        if vim.fn.executable(venv) == 1 then
          return venv
        end
        return "python3"
      end

      -- Use Mason's debugpy so it doesn't need to be in every project venv
      local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
      require("dap-python").setup(debugpy_path)

      -- ------------------------------------------------------------
      -- FastAPI / Uvicorn launch (VS Code equivalent)
      -- name: "Python Debugger: FastAPI"
      -- type: "debugpy"
      -- request: "launch"
      -- module: "uvicorn"
      -- args: ["app:fast_app", "--reload"]
      -- ------------------------------------------------------------
      dap.configurations.python = dap.configurations.python or {}

      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "Debug: Current File",
        program = "${file}",
        console = "integratedTerminal",
        cwd = "${workspaceFolder}",
        env = {
          PYTHONPATH = "${workspaceFolder}",
          LOG_LEVEL = "INFO",
          PYTHONUNBUFFERED = "1",
        },
        justMyCode = false,
      })

      table.insert(dap.configurations.python, {
        type = "python",
        request = "launch",
        name = "FastAPI (uvicorn: app:fast_app --reload)",
        module = "uvicorn",
        args = { "app:fast_app", "--reload" },
        justMyCode = true,
        console = "integratedTerminal",
      })
    end,
  },
}

