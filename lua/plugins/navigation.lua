return {
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local api = require("nvim-tree.api")

      local function on_attach(bufnr)
        local opts = function(desc)
          return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end
        api.config.mappings.default_on_attach(bufnr)
        vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
        vim.keymap.set("n", "<Right>", api.node.open.edit, opts("Open"))
        vim.keymap.set("n", "j", api.node.navigate.parent_close, opts("Close Directory"))
        vim.keymap.set("n", "<Left>", api.node.navigate.parent_close, opts("Close Directory"))
      end

      require("nvim-tree").setup({
        on_attach = on_attach,
        view = { width = 35 },
        update_focused_file = { enable = true, update_root = false },
        respect_buf_cwd = true,
        filters = {
          dotfiles = false,
          git_ignored = false,
          custom = {
            "^\\.claude$",
            "^\\.aws-sam$",
            "^\\.git$",
            "^\\.github$",
            "^\\.idea$",
            "^\\.mypy_cache$",
            "^\\.pytest_cache$",
            "^\\.venv$",
            "^__pycache__$",
          },
        },
        renderer = {
          highlight_git = true,
          highlight_opened_files = "name",
          indent_markers = { enable = true },
          icons = {
            show = { folder_arrow = true },
            glyphs = {
              folder = {
                arrow_closed = "▸",
                arrow_open = "▾",
                default = "󰉋",
                open = "󰝰",
                empty = "󰉌",
                empty_open = "󰅪",
                symlink = "󰉫",
                symlink_open = "󰉬",
              },
              git = {
                unstaged  = "~",
                staged    = "+",
                unmerged  = "!",
                renamed   = "»",
                untracked = "?",
                deleted   = "-",
                ignored   = " ",
              },
            },
          },
        },
        git = { enable = true, ignore = false, show_on_dirs = false },
      })

      -- Folder icon colors
      vim.api.nvim_set_hl(0, "NvimTreeFolderIcon",        { fg = "#F0C060" })
      vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderIcon",  { fg = "#F0C060" })
      vim.api.nvim_set_hl(0, "NvimTreeFolderName",        { fg = "#8BAFD1" })
      vim.api.nvim_set_hl(0, "NvimTreeOpenedFolderName",  { fg = "#C0D8F0", bold = true })
      vim.api.nvim_set_hl(0, "NvimTreeEmptyFolderName",   { fg = "#6A8FAD" })
      vim.api.nvim_set_hl(0, "NvimTreeFolderSymlinkIcon", { fg = "#C792EA" })
      vim.api.nvim_set_hl(0, "NvimTreeArrowOpen",         { fg = "#89DDFF" })
      vim.api.nvim_set_hl(0, "NvimTreeArrowClosed",       { fg = "#89DDFF" })

      -- Make all .env* files use the same lock icon as .env
      local ok, devicons = pcall(require, "nvim-web-devicons")
      if ok then
        local orig_get_icon = devicons.get_icon
        devicons.get_icon = function(name, ext, opts)
          if type(name) == "string" and name ~= ".env" and name:match("^%.env") then
            local icon, hl = orig_get_icon(".env", nil, opts)
            if icon then return icon, hl end
          end
          return orig_get_icon(name, ext, opts)
        end
      end

      -- Open nvim-tree automatically on startup
      vim.api.nvim_create_autocmd("VimEnter", {
        callback = function(data)
          local real_file = vim.fn.filereadable(data.file) == 1
          local no_name = data.file == "" and vim.bo[data.buf].buftype == ""
          if not real_file and not no_name then
            return
          end
          -- Open tree without stealing focus; find the file if one was given
          require("nvim-tree.api").tree.toggle({ focus = false, find_file = true })
        end,
      })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup()
    end,
  },
}
