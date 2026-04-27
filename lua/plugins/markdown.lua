return {
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },

    -- Build the web app (this is what mkdp#util#install() ultimately does)
    build = "cd app && npm install",

    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
      -- optional: pick a browser; omit to use default
      -- vim.g.mkdp_browser = "Google Chrome"
    end,
  },
}
