return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup()

      -- Keymaps for Harpoon
      -- Add file to harpoon
      vim.keymap.set("n", "<leader>ha", function()
        harpoon:list():add()
        vim.notify("Added to Harpoon", vim.log.levels.INFO)
      end, { desc = "Harpoon: Add file" })

      -- Toggle harpoon menu
      vim.keymap.set("n", "<leader>hh", function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = "Harpoon: Toggle menu" })

      -- Navigate to specific files (1-4)
      vim.keymap.set("n", "<leader>h1", function()
        harpoon:list():select(1)
      end, { desc = "Harpoon: File 1" })

      vim.keymap.set("n", "<leader>h2", function()
        harpoon:list():select(2)
      end, { desc = "Harpoon: File 2" })

      vim.keymap.set("n", "<leader>h3", function()
        harpoon:list():select(3)
      end, { desc = "Harpoon: File 3" })

      vim.keymap.set("n", "<leader>h4", function()
        harpoon:list():select(4)
      end, { desc = "Harpoon: File 4" })

      -- Navigate through list
      vim.keymap.set("n", "<leader>hn", function()
        harpoon:list():next()
      end, { desc = "Harpoon: Next" })

      vim.keymap.set("n", "<leader>hp", function()
        harpoon:list():prev()
      end, { desc = "Harpoon: Previous" })

      -- Clear all
      vim.keymap.set("n", "<leader>hc", function()
        harpoon:list():clear()
        vim.notify("Harpoon cleared", vim.log.levels.INFO)
      end, { desc = "Harpoon: Clear all" })
    end,
  },
}

