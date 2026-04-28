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
              { kind = "empty", hl = "StatusLine" },
              { kind = "diagnostics" },
              { kind = "branch" },
              { kind = "mode" },
              { kind = "ruler" },
            },
          },
        },
        statuscolumn = false,
        winbar = false,
        tabline = false,
      })
    end,
  },
}
