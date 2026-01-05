return {
  {
    "mbbill/undotree",
    config = function()
      -- Configure undotree
      vim.g.undotree_WindowLayout = 2  -- Layout style
      vim.g.undotree_ShortIndicators = 1  -- Use short time indicators
      vim.g.undotree_SetFocusWhenToggle = 1  -- Focus undotree when opened

      -- Keymaps for undotree
      vim.keymap.set("n", "<leader>u", ":UndotreeToggle<CR>", { 
        silent = true, 
        desc = "Toggle Undotree" 
      })
    end,
  },
}

