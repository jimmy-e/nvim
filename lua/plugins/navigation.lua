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
        },
      })

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
