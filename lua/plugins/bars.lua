return {
  {
    "OXY2DEV/bars.nvim",
    lazy = false,
    config = function()
      vim.opt.laststatus = 3

      require("bars").setup({
        statusline = {
          default = {
            components = {
              {
                kind = "custom",
                value = function(buffer, window)
                  return require("buffer_tabs").render(buffer, window)
                end,
              },
            },
          },
        },
        statuscolumn = false,
        winbar = false,
        tabline = false,
      })

      require("bars.highlights").setup()
      require("buffer_tabs").setup_highlights()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("BufferTabsHighlights", { clear = true }),
        callback = function()
          require("buffer_tabs").setup_highlights()
        end,
      })
      require("bars.statusline"):start()
    end,
  },
}
