return {
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Keymaps applied whenever any LSP attaches to a buffer
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
          end
          map("n", "gd",         vim.lsp.buf.definition,      "Go to definition")
          map("n", "gD",         vim.lsp.buf.declaration,     "Go to declaration")
          map("n", "gr",         vim.lsp.buf.references,      "References")
          map("n", "gi",         vim.lsp.buf.implementation,  "Go to implementation")
          map("n", "K",          vim.lsp.buf.hover,           "Hover docs")
          map("n", "<leader>rn", vim.lsp.buf.rename,          "Rename symbol")
          map("n", "<leader>ca", vim.lsp.buf.code_action,     "Code action")
          map("n", "<leader>ds", vim.lsp.buf.document_symbol, "Document symbols")
        end,
      })

      -- Python
      vim.lsp.config("pyright", {
        capabilities = capabilities,
        settings = {
          python = {
            analysis = {
              typeCheckingMode = "basic",
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "openFilesOnly",
            },
          },
        },
      })

      -- TypeScript / JavaScript
      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
      })

      -- Lua (Neovim config files)
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            diagnostics = { globals = { "vim" } },
            telemetry = { enable = false },
          },
        },
      })

      -- YAML
      vim.lsp.config("yamlls", {
        capabilities = capabilities,
      })

      vim.lsp.enable({ "pyright", "ts_ls", "lua_ls", "yamlls" })

      -- Diagnostic display
      vim.diagnostic.config({
        virtual_text = { prefix = "●", source = "if_many" },
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded", source = "always" },
      })
    end,
  },
}
