return {
  -- Treesitter for superior syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      -- Install parsers (no-op if already installed)
      require("nvim-treesitter").install({
        "python",
        "lua",
        "vim",
        "vimdoc",
        "json",
        "markdown",
        "markdown_inline",
        "bash",
        "typescript",
        "tsx",
        "javascript",
        "html",
        "css",
        "yaml",
        "toml",
        "sql",
        "dockerfile",
        "regex",
        "comment",
      })

      -- Enable treesitter highlighting for all filetypes (silently skip unsupported ones)
      vim.api.nvim_create_autocmd("BufReadPost", {
        pattern = "*",
        callback = function()
          pcall(vim.treesitter.start)
        end,
      })

      -- Quick diagnostic command
      vim.api.nvim_create_user_command("TSStatus", function()
        local bufnr = vim.api.nvim_get_current_buf()
        local ft = vim.bo[bufnr].filetype
        local parser_ok = pcall(vim.treesitter.get_parser, bufnr, ft)
        local highlighter_ok = false
        if vim.treesitter.highlighter and vim.treesitter.highlighter.active then
          highlighter_ok = vim.treesitter.highlighter.active[bufnr] ~= nil
        end
        vim.notify(
          string.format("TSStatus: ft=%s | parser=%s | highlighter=%s", ft, parser_ok and "ok" or "no", tostring(highlighter_ok)),
          vim.log.levels.INFO
        )
      end, { desc = "Show Tree-sitter parser/highlighter status for current buffer" })
    end,
  },

  -- Rainbow delimiters (no custom highlight overrides)
  {
    "HiPhish/rainbow-delimiters.nvim",
  },

  -- Indent guides (no custom colors)
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    config = function()
      require("ibl").setup()
    end,
  },

  -- Show current function/class context at top of screen
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "BufReadPost",
    opts = {
      max_lines = 3,
      min_window_height = 20,
      trim_scope = "outer",
    },
  },

  -- Highlight all references to symbol under cursor
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    config = function()
      require("illuminate").configure({
        providers = { "lsp", "treesitter", "regex" },
        delay = 120,
        under_cursor = true,
        min_count_to_highlight = 2,
      })
      vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#2d3f6c", underline = false })
      vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#2d3f6c" })
      vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#3d2f4c" })
    end,
  },

  -- Colorful TODO/FIXME/NOTE/HACK/WARN markers
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufReadPost",
    opts = {
      signs = true,
      keywords = {
        FIX  = { icon = " ", color = "error",   alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", color = "default", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint",    alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test",   alt = { "TESTING", "PASSED", "FAILED" } },
      },
    },
  },

  -- Color highlighter - show colors in the code
  {
    "norcalli/nvim-colorizer.lua",
    event = "BufReadPost",
    config = function()
      require("colorizer").setup({
        "*",
      }, {
        RGB = true,
        RRGGBB = true,
        names = true,
        RRGGBBAA = true,
        rgb_fn = true,
        hsl_fn = true,
        css = true,
        css_fn = true,
        mode = "background",
      })
      vim.cmd("ColorizerAttachToBuffer")
    end,
  },
}
