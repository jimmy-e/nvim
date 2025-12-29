local M = {}

local function lines()
  return {
    "NEOVIM CHEAT SHEET",
    "================================================================",
    "",
    "PROJECT / GENERAL",
    "  <Space>w            Save file",
    "  <Space>q            Quit window",
    "  <Space>e            Toggle file tree",
    "  <Space>ff           Find files (Telescope)",
    "  <Space>fg           Live grep",
    "  <Space>fb           Buffers",
    "  <Space>?            Open this cheat sheet",
    "",
    "TERMINAL / RUN",
    "  <Space>t            Open terminal (bottom split)",
    "  <Space>rp           Run current Python file (.venv)",
    "",
    "AI / LLM (AVANTE)",
    "  :AvanteChat         Open persistent AI chat",
    "",
    "AI / CODE COMPLETION",
    "  Ctrl+Space          Trigger completion menu",
    "  Tab                 Accept completion (AI / LSP)",
    "  Shift+Tab           Previous completion",
    "  Enter               Accept completion (fallback)",
    "  [AI]                Copilot suggestion",
    "  [LSP]               Language server suggestion",
    "  [Buf]               Buffer word suggestion",
    "",
    "DEBUGGER (PYTHON / DEBUGPY)",
    "  <Space>dc           Start / Continue debug",
    "  <Space>dn           Step over",
    "  <Space>di           Step into",
    "  <Space>do           Step out",
    "  <Space>db           Toggle breakpoint",
    "  <Space>dB           Conditional breakpoint",
    "  <Space>dr           Open debug REPL",
    "  <Space>du           Toggle debug UI",
    "  <Space>dq           Stop debugging",
    "",
    "GIT / VERSION CONTROL (GitLens equivalent)",
    "  <Space>gs           Git status (Neogit)",
    "",
    "  Gitsigns (inline blame & hunks)",
    "  ]c / [c             Next / previous git hunk",
    "  <Space>gb           Toggle line blame (inline)",
    "  <Space>gk           Toggle hover blame popup",
    "  <Space>gh           Preview hunk",
    "  <Space>gr           Reset hunk",
    "  <Space>gd           Diff current file",
    "  <Space>gB           Full blame info (commit details)",
    "",
    "  Diffview (diffs / history)",
    "  <Space>go           Open diff view (Diffview)",
    "  <Space>gq           Close diff view",
    "  <Space>gf           File commit history",
    "  <Space>gF           Repo commit history",
    "  :DiffviewOpen       Open repo diff view",
    "  :DiffviewClose      Close diff view",
    "  :DiffviewFileHistory  Repo history",
    "  :DiffviewFileHistory %  Current file history",
    "",
    "  Statusline",
    "     Author — message   Blame for current line (from gitsigns)",
    "",
    "  Inside Neogit",
    "  s                   Stage hunk / file",
    "  u                   Unstage hunk / file",
    "  c                   Commit",
    "  p                   Push",
    "  P                   Pull",
    "  q                   Close Neogit",
    "",
    "WINDOWS / SPLITS",
    "  <C-w>w              Cycle splits",
    "  <C-h/j/k/l>         Move between splits",
    "  :q                  Close current split",
    "",
    "MODES",
    "  i                   Insert mode",
    "  Esc                 Normal mode",
    "  v                   Visual (character)",
    "  V                   Visual (line)",
    "  Ctrl+v              Visual (block)",
    "",
    "COMMON MOTIONS",
    "  h j k l             Left / down / up / right",
    "  w / b / e           Next word / prev word / end word",
    "  0 / ^ / $           Line start / first text / end",
    "  gg / G              Top / bottom of file",
    "  { / }               Previous / next paragraph",
    "",
    "SEARCH",
    "  /text               Search forward",
    "  ?text               Search backward",
    "  n / N               Next / previous match",
    "",
    "EDITING",
    "  yy                  Copy (yank) line",
    "  p                   Paste below",
    "  dd                  Delete line",
    "  u / Ctrl+r          Undo / redo",
    "  ciw / diw           Change / delete word",
    "  o / O               New line below / above",
    "",
    "COPY WORKFLOW (VS CODE STYLE)",
    "  Esc → v → move → y → p",
    "",
    "Close this cheat sheet: press 'q' or Esc",
  }
end

function M.open()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines())
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype = "markdown"

  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })

  vim.wo[win].wrap = false
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false

  -- Close with q or Esc
  vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = buf, silent = true })
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", { buffer = buf, silent = true })
end

return M
