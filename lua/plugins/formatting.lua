return {
  {
    "stevearc/conform.nvim",
    config = function()
      local conform = require("conform")

      conform.setup({
        formatters_by_ft = {
          python = { "black" },
          javascript = { "prettier" },
          typescript = { "prettier" },
          json = { "prettier" },
          yaml = { "prettier" },
          markdown = { "prettier" },
        },
        formatters = {
          black = {
            -- Bypass pyenv shim to avoid timeout
            command = vim.fn.expand("~/.pyenv/versions/3.13.3/bin/black"),
          },
        },
      })

      vim.api.nvim_create_autocmd("BufWritePre", {
        callback = function(args)
          conform.format({
            bufnr = args.buf,
            lsp_fallback = true,
            timeout_ms = 5000,
          })
        end,
      })
    end,
  },
}
