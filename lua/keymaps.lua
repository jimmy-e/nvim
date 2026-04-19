-- ============================================================
-- Keymaps
-- ============================================================

---------------------------------------------------------------
-- Custom motion layout: i=up, k=down, j=left, l=right, h=insert
---------------------------------------------------------------
-- Normal mode
vim.cmd("nnoremap i k")
vim.cmd("nnoremap k j")
vim.cmd("nnoremap j h")
vim.cmd("nnoremap h i")

-- Visual mode (operator-pending mode untouched: ciw, di", etc. still work)
vim.cmd("xnoremap i k")
vim.cmd("xnoremap k j")
vim.cmd("xnoremap j h")

---------------------------------------------------------------
-- Core file / editor commands
---------------------------------------------------------------
vim.keymap.set("n", "<leader>w", ":w<CR>", { silent = true, desc = "Save" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { silent = true, desc = "Quit" })

-- Toggle auto-save
vim.g.autosave_enabled = true  -- Enabled by default
vim.keymap.set("n", "<leader>ta", function()
  vim.g.autosave_enabled = not vim.g.autosave_enabled
  if vim.g.autosave_enabled then
    vim.notify("Auto-save enabled", vim.log.levels.INFO)
  else
    vim.notify("Auto-save disabled", vim.log.levels.WARN)
  end
end, { desc = "Toggle auto-save" })

---------------------------------------------------------------
-- File tree
---------------------------------------------------------------
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true, desc = "File Tree" })
-- iTerm2 Cmd+1 sends \x1b[57P, which neovim translates to <F1>
-- Toggle focus: tree ↔ editor
vim.keymap.set("n", "<F1>", function()
  local api = require("nvim-tree.api")
  if api.tree.is_visible() then
    vim.cmd("wincmd p")
  else
    api.tree.open()
  end
end, { silent = true, noremap = true, desc = "File Tree (Cmd+1)" })
-- iTerm2 Cmd+Shift+O sends \x1b[57Q, which translates to <F2>
-- Toggle tree show/hide
vim.keymap.set("n", "<F2>", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle Tree (Cmd+Shift+1)" })
-- iTerm2 Cmd+T sends \x1b[57S, which translates to <F4>
-- Toggle floating terminal
vim.keymap.set("n", "<F4>", function()
  require("floating_terminal").toggle()
end, { silent = true, noremap = true, desc = "Terminal (Cmd+T)" })
vim.keymap.set("t", "<F4>", function()
  require("floating_terminal").toggle()
end, { silent = true, noremap = true, desc = "Terminal (Cmd+T)" })

---------------------------------------------------------------
-- Telescope
---------------------------------------------------------------
local function smart_find_files()
  local builtin = require("telescope.builtin")
  local action_state = require("telescope.actions.state")
  local actions = require("telescope.actions")

  local function open_picker(opts)
    builtin.find_files(vim.tbl_extend("force", {
      attach_mappings = function(prompt_bufnr, map)
        map("i", "/", function()
          vim.api.nvim_feedkeys("/", "n", false)
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(prompt_bufnr) then return end
            local prompt = action_state.get_current_picker(prompt_bufnr):_get_prompt()
            if prompt:sub(-1) == "/" then
              actions.close(prompt_bufnr)
              builtin.find_files({
                default_text = prompt:sub(1, -2),
                find_command = { "fd", "--type", "d", "--hidden", "--exclude", ".git" },
                attach_mappings = function(dir_bufnr, dir_map)
                  local telescope_actions = require("telescope.actions")
                  local function select_dir()
                    local selection = action_state.get_selected_entry()
                    telescope_actions.close(dir_bufnr)
                    if not selection then return end
                    local dir_path = vim.fn.getcwd() .. "/" .. selection.value
                    local tree = require("nvim-tree.api")
                    tree.tree.open({ focus = true })
                    vim.schedule(function()
                      tree.tree.find_file({ buf = dir_path, open = true, focus = true })
                      vim.schedule(function() tree.node.open.edit() end)
                    end)
                  end
                  dir_map("i", "<CR>", select_dir)
                  dir_map("n", "<CR>", select_dir)
                  return true
                end,
              })
            end
          end)
        end)
        return true
      end,
    }, opts or {}))
  end

  open_picker()
end

vim.keymap.set("n", "<leader>ff", smart_find_files, { silent = true, desc = "Find Files" })
vim.keymap.set("n", "<F3>", smart_find_files, { silent = true, desc = "Find Files (Cmd+Shift+O)" })

vim.keymap.set("n", "<leader>fg", function()
  require("telescope.builtin").live_grep()
end, { silent = true, desc = "Live Grep" })

vim.keymap.set("n", "<leader>fb", function()
  require("telescope.builtin").buffers()
end, { silent = true, desc = "Buffers" })

---------------------------------------------------------------
-- Git (Neogit)
---------------------------------------------------------------
vim.keymap.set("n", "<leader>gs", ":Neogit<CR>", { silent = true, desc = "Neogit Status" })

---------------------------------------------------------------
-- Terminal (floating, persistent session)
---------------------------------------------------------------
vim.keymap.set("n", "<leader>\\", function()
  require("floating_terminal").toggle()
end, { desc = "Toggle Floating Terminal" })

vim.keymap.set("t", "<leader>\\", function()
  require("floating_terminal").toggle()
end, { desc = "Toggle Floating Terminal" })

---------------------------------------------------------------
-- Window navigation (not motions)
---------------------------------------------------------------
vim.keymap.set("n", "<C-h>", "<C-w>k", { desc = "Window Up" })
vim.keymap.set("n", "<C-j>", "<C-w>h", { desc = "Window Left" })
vim.keymap.set("n", "<C-k>", "<C-w>j", { desc = "Window Down" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Window Right" })

---------------------------------------------------------------
-- Run Python file in venv
---------------------------------------------------------------
vim.keymap.set("n", "<leader>rp", function()
  vim.cmd("botright split | terminal ./.venv/bin/python " .. vim.fn.expand("%"))
end, { desc = "Run Python (.venv)" })

---------------------------------------------------------------
-- Debugger (nvim-dap) — lazy-safe
---------------------------------------------------------------
vim.keymap.set("n", "<leader>dc", function()
  require("dap").continue()
end, { desc = "Debug: Continue" })

vim.keymap.set("n", "<leader>dn", function()
  require("dap").step_over()
end, { desc = "Debug: Step Over" })

vim.keymap.set("n", "<leader>di", function()
  require("dap").step_into()
end, { desc = "Debug: Step Into" })

vim.keymap.set("n", "<leader>do", function()
  require("dap").step_out()
end, { desc = "Debug: Step Out" })

vim.keymap.set("n", "<leader>db", function()
  require("dap").toggle_breakpoint()
end, { desc = "Debug: Toggle Breakpoint" })

vim.keymap.set("n", "<leader>dB", function()
  require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
end, { desc = "Debug: Conditional Breakpoint" })

vim.keymap.set("n", "<leader>dr", function()
  require("dap").repl.open()
end, { desc = "Debug: REPL" })

vim.keymap.set("n", "<leader>dl", function()
  require("dap").run_last()
end, { desc = "Debug: Run Last" })

vim.keymap.set("n", "<leader>dq", function()
  require("dap").terminate()
end, { desc = "Debug: Terminate" })

vim.keymap.set("n", "<leader>du", function()
  require("dapui").toggle()
end, { desc = "Debug: Toggle UI" })

---------------------------------------------------------------
-- SSH Remote
---------------------------------------------------------------
vim.keymap.set("n", "<leader>sr", function()
  require("ssh_remote").pick()
end, { desc = "SSH Remote: pick host" })

---------------------------------------------------------------
-- Cheat sheet
---------------------------------------------------------------
vim.keymap.set("n", "<leader>?", function()
  require("cheatsheet").open()
end, { desc = "Cheat Sheet" })

---------------------------------------------------------------
-- Previews
---------------------------------------------------------------
vim.keymap.set(
  "n",
  "<leader>mp",
  function() require("markdown_preview").open() end,
  { desc = "Markdown Preview Popup", silent = true }
)

vim.keymap.set(
  "n",
  "<leader>cv",
  "<cmd>CsvViewToggle<CR>",
  { desc = "CSV Table View Toggle", silent = true }
)

vim.keymap.set("n", "<leader>df", function()
  require("debug.fastapi_aws").pick_and_debug()
end, { desc = "Debug FastAPI: pick AWS profile -> ae -> start -> debugpy -> attach" })

---------------------------------------------------------------
-- Zen mode
---------------------------------------------------------------
vim.keymap.set("n", "<leader>z", "<cmd>ZenMode<CR>", { desc = "Focus mode (Zen)" })

---------------------------------------------------------------
-- Claude Code AI
---------------------------------------------------------------
local claude_session_started = false

-- Toggle Claude — shows session picker only on first open per Neovim session
vim.keymap.set("n", "<leader>at", function()
  if claude_session_started then
    -- Already launched this session, just toggle
    vim.cmd("ClaudeCode")
    return
  end

  -- First time opening — ask how to start
  vim.ui.select(
    { "New session", "Continue last session", "Pick session" },
    { prompt = "Claude Code:" },
    function(choice)
      if not choice then return end
      claude_session_started = true
      if choice == "New session" then
        vim.cmd("ClaudeCode")
      elseif choice == "Continue last session" then
        vim.cmd("ClaudeCode --continue")
      elseif choice == "Pick session" then
        vim.cmd("ClaudeCode --resume")
      end
    end
  )
end, { desc = "Claude: Toggle/session picker" })

-- Switch to a new session or pick a different one mid-session
vim.keymap.set("n", "<leader>as", function()
  claude_session_started = false
  -- Close current if open
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_config(win).relative ~= "" then
      local buf = vim.api.nvim_win_get_buf(win)
      if vim.api.nvim_buf_get_name(buf):match("claude") then
        vim.cmd("ClaudeCode")
        break
      end
    end
  end
  -- Show picker for next open
  vim.notify("Claude session reset — next <leader>at will show session picker", vim.log.levels.INFO)
end, { desc = "Claude: Switch session" })

vim.keymap.set("n", "<leader>af", "<cmd>ClaudeCodeFocus<CR>", { desc = "Claude: Focus panel" })
vim.keymap.set("v", "<leader>aa", "<cmd>ClaudeCodeSend<CR>", { desc = "Claude: Send selection" })
vim.keymap.set("n", "<leader>am", "<cmd>ClaudeCodeSelectModel<CR>", { desc = "Claude: Select model" })
vim.keymap.set("n", "<leader>ab", "<cmd>ClaudeCodeAdd %<CR>", { desc = "Claude: Add current file" })

---------------------------------------------------------------
-- Color/Highlighting test and toggle commands
---------------------------------------------------------------
-- Test command to verify syntax highlighting is working
vim.keymap.set("n", "<leader>th", function()
  -- Check if Treesitter is active
  local ts_ok, ts_configs = pcall(require, "nvim-treesitter.configs")
  if ts_ok then
    vim.notify("Treesitter is loaded", vim.log.levels.INFO)
  else
    vim.notify("Treesitter NOT loaded", vim.log.levels.ERROR)
  end
  
  -- Check current buffer parser
  local has_parser = vim.treesitter.language.get_lang(vim.bo.filetype)
  if has_parser then
    vim.notify("Parser found for " .. vim.bo.filetype, vim.log.levels.INFO)
  else
    vim.notify("NO parser for " .. vim.bo.filetype, vim.log.levels.WARN)
  end
  
  -- Force enable Treesitter highlighting
  vim.cmd("TSBufEnable highlight")
  vim.notify("Forced Treesitter highlighting ON", vim.log.levels.INFO)
end, { desc = "Toggle highlights test" })

-- Quick command to force Treesitter
vim.keymap.set("n", "<leader>tf", function()
  local ts_ok = pcall(require, "nvim-treesitter")
  if not ts_ok then
    vim.notify("Treesitter NOT installed!", vim.log.levels.ERROR)
    vim.notify("Run :Lazy sync to install it", vim.log.levels.WARN)
    return
  end
  
  pcall(vim.cmd, "TSBufEnable highlight")
  vim.cmd("edit")
  vim.notify("Forced Treesitter refresh", vim.log.levels.INFO)
end, { desc = "Force Treesitter refresh" })

-- Command to check what's highlighting the file
vim.keymap.set("n", "<leader>tc", function()
  local buf = vim.api.nvim_get_current_buf()
  local ft = vim.bo[buf].filetype
  
  vim.notify("Filetype: " .. ft, vim.log.levels.INFO)
  vim.notify("Syntax: " .. vim.bo[buf].syntax, vim.log.levels.INFO)
  
  -- Check if treesitter is active
  local ts_highlighter = vim.treesitter.highlighter.active[buf]
  if ts_highlighter then
    vim.notify("✓ Treesitter IS active!", vim.log.levels.INFO)
  else
    vim.notify("✗ Treesitter NOT active", vim.log.levels.WARN)
  end
end, { desc = "Check syntax highlighting status" })

---------------------------------------------------------------
-- Jump up/down 20 lines at a time
---------------------------------------------------------------
vim.keymap.set("n", "<leader>J", "20j", { desc = "Jump down 20 lines" })
vim.keymap.set("n", "<leader>K", "20k", { desc = "Jump up 20 lines" })

---------------------------------------------------------------
-- Move lines up/down (Space+j/k)
---------------------------------------------------------------
-- Normal mode: move current line
vim.keymap.set("n", "<leader>k", function()
  local line = vim.fn.line(".")
  if line > 1 then
    vim.cmd("move " .. (line - 2))
    vim.cmd("normal! ==")
  end
end, { silent = true, desc = "Move line up" })

vim.keymap.set("n", "<leader>j", function()
  local line = vim.fn.line(".")
  local lastline = vim.fn.line("$")
  if line < lastline then
    vim.cmd("move " .. (line + 1))
    vim.cmd("normal! ==")
  end
end, { silent = true, desc = "Move line down" })

-- Visual mode: move selected lines
vim.keymap.set("v", "<leader>k", function()
  vim.cmd("'<,'>move '<-2")
  vim.cmd("normal! gv=gv")
end, { silent = true, desc = "Move selection up" })

vim.keymap.set("v", "<leader>j", function()
  vim.cmd("'<,'>move '>+1")
  vim.cmd("normal! gv=gv")
end, { silent = true, desc = "Move selection down" })

---------------------------------------------------------------
-- Code Folding (VSCode-style collapse)
---------------------------------------------------------------
-- Collapse/Expand all (VSCode-like) - using arrow keys
vim.keymap.set("n", "<leader><up>", function()
  -- Check fold settings
  local foldmethod = vim.opt.foldmethod:get()
  local foldenable = vim.opt.foldenable:get()
  
  if not foldenable then
    vim.notify("Folding is disabled! Run :set foldenable", vim.log.levels.WARN)
    return
  end
  
  vim.cmd("normal! zM")  -- Close all folds
  vim.notify("Collapsed all (foldmethod=" .. foldmethod .. ")", vim.log.levels.INFO)
end, { desc = "Collapse all folds" })

vim.keymap.set("n", "<leader><down>", function()
  vim.cmd("normal! zR")  -- Open all folds
  vim.notify("Expanded all", vim.log.levels.INFO)
end, { desc = "Expand all folds" })

-- Individual fold control
vim.keymap.set("n", "<leader>fc", "zc", { desc = "Close fold under cursor" })
vim.keymap.set("n", "<leader>fo", "zo", { desc = "Open fold under cursor" })
vim.keymap.set("n", "<leader>ft", "za", { desc = "Toggle fold under cursor" })

-- Also support za (toggle) on <Space> for quick access
vim.keymap.set("n", "<leader><Space>", "za", { desc = "Toggle fold" })

-- Debug command to check fold settings
vim.keymap.set("n", "<leader>fd", function()
  print("Fold settings:")
  print("  foldmethod: " .. vim.opt.foldmethod:get())
  print("  foldenable: " .. tostring(vim.opt.foldenable:get()))
  print("  foldlevel: " .. vim.opt.foldlevel:get())
  print("  foldcolumn: " .. vim.opt.foldcolumn:get())
end, { desc = "Debug fold settings" })
