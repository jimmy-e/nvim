return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        styles = { comments = { "italic" } },
        integrations = {
          treesitter = true,
          gitsigns = true,
          nvimtree = true,
          telescope = true,
          neogit = true,
          cmp = true,
          native_lsp = { enabled = true },
        },
      })

      vim.cmd.colorscheme("catppuccin")
    end,
  },

  { "nvim-tree/nvim-web-devicons" },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local function blame_component()
        -- gitsigns populates this when it has blame info for the current line
        local b = vim.b.gitsigns_blame_line_dict
        if not b or not b.author or b.author == "" then
          return ""
        end

        local summary = b.summary or ""
        if summary ~= "" then
          summary = " — " .. summary
        end

        return string.format(" %s%s", b.author, summary)
      end

      require("lualine").setup({
        options = {
          theme = "catppuccin",
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = { "filename", blame_component },
          lualine_x = { "diagnostics" },
          lualine_y = { "filetype" },
          lualine_z = { "location" },
        },
      })
    end,
  },
}
