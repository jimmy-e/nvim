local M = {}

function M.setup_highlights()
  vim.api.nvim_set_hl(0, "FooterTabsFill", { fg = "#6e6a73", bg = "#1b1a1f" })
  vim.api.nvim_set_hl(0, "FooterTab", { fg = "#b8b4bd", bg = "#232126" })
  vim.api.nvim_set_hl(0, "FooterTabEdge", { fg = "#1b1a1f", bg = "#1b1a1f" })
  vim.api.nvim_set_hl(0, "FooterTabActive", { fg = "#f3f1f5", bg = "#2b2830", bold = true })
  vim.api.nvim_set_hl(0, "FooterTabActiveAccent", { fg = "#e6c15a", bg = "#2b2830", bold = true })
  vim.api.nvim_set_hl(0, "FooterTabMeta", { fg = "#9b96a3", bg = "#1b1a1f" })
end

local function is_terminal_session_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local bo = vim.bo[bufnr]
  return bo.buflisted and bo.buftype == "terminal" and vim.b[bufnr].bottom_terminal_session == true
end

local function is_file_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local bo = vim.bo[bufnr]
  return bo.buflisted and bo.buftype == ""
end

local function is_tab_buffer(bufnr)
  return is_file_buffer(bufnr) or is_terminal_session_buffer(bufnr)
end

local function listed_file_buffers()
  local buffers = {}

  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if is_file_buffer(info.bufnr) then
      table.insert(buffers, info.bufnr)
    end
  end

  table.sort(buffers)
  return buffers
end

local function listed_tab_buffers()
  local buffers = {}

  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if is_tab_buffer(info.bufnr) then
      table.insert(buffers, info.bufnr)
    end
  end

  table.sort(buffers)
  return buffers
end

local function listed_terminal_session_buffers()
  local buffers = {}

  for _, info in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if is_terminal_session_buffer(info.bufnr) then
      table.insert(buffers, info.bufnr)
    end
  end

  table.sort(buffers)
  return buffers
end

local function current_file_buffer()
  local current = vim.api.nvim_get_current_buf()
  if is_file_buffer(current) then
    return current
  end

  local alternate = vim.fn.bufnr("#")
  if alternate > 0 and is_file_buffer(alternate) then
    return alternate
  end

  return nil
end

local function cycle(step)
  local buffers = listed_file_buffers()
  if #buffers == 0 then
    return
  end

  local current = current_file_buffer() or buffers[1]
  local index = 1

  for i, bufnr in ipairs(buffers) do
    if bufnr == current then
      index = i
      break
    end
  end

  local next_index = ((index - 1 + step) % #buffers) + 1
  vim.api.nvim_set_current_buf(buffers[next_index])
end

local function display_name(bufnr)
  if is_terminal_session_buffer(bufnr) then
    return vim.api.nvim_buf_get_name(bufnr)
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  local label = name == "" and "[No Name]" or vim.fn.fnamemodify(name, ":t")

  if vim.bo[bufnr].modified then
    label = label .. " [+]"
  end

  if vim.fn.strdisplaywidth(label) > 24 then
    label = vim.fn.strcharpart(label, 0, 21) .. "..."
  end

  return label
end

local function file_icon(bufnr)
  if is_terminal_session_buffer(bufnr) then
    return " ", nil
  end

  local ok, devicons = pcall(require, "nvim-web-devicons")
  if not ok then
    return "", nil
  end

  local name = vim.api.nvim_buf_get_name(bufnr)
  local filename = name == "" and "text" or vim.fn.fnamemodify(name, ":t")
  local extension = vim.fn.fnamemodify(filename, ":e")
  local icon, hl = devicons.get_icon(filename, extension, { default = true })
  return (icon or "") ~= "" and (icon .. " ") or "", hl
end

local function tree_prefix()
  local ok, api = pcall(require, "nvim-tree.api")
  if not ok or not api.tree.is_visible() then
    return ""
  end

  local tree_win = api.tree.winid()
  if not tree_win or not vim.api.nvim_win_is_valid(tree_win) then
    return ""
  end

  local pos = vim.api.nvim_win_get_position(tree_win)
  if not pos or pos[2] ~= 0 then
    return ""
  end

  local width = vim.api.nvim_win_get_width(tree_win)
  return string.rep(" ", width + 1)
end

local function mode_label()
  local mode = vim.api.nvim_get_mode().mode
  local labels = {
    n = "NORMAL",
    no = "NORMAL",
    nov = "NORMAL",
    noV = "NORMAL",
    ["no\22"] = "NORMAL",
    i = "INSERT",
    ic = "INSERT",
    ix = "INSERT",
    v = "VISUAL",
    V = "V-LINE",
    ["\22"] = "V-BLOCK",
    c = "COMMAND",
    R = "REPLACE",
    s = "SELECT",
    S = "S-LINE",
    t = "TERMINAL",
  }

  return labels[mode] or mode:upper()
end

local function current_branch(bufnr)
  local branch = vim.b[bufnr].gitsigns_head
  if type(branch) == "string" and branch ~= "" then
    return branch
  end

  return nil
end

local function location()
  return string.format("%d:%d", vim.fn.line("."), vim.fn.col("."))
end

local function progress()
  local line = vim.fn.line(".")
  local total = vim.fn.line("$")

  if line <= 1 then
    return "Top"
  elseif line >= total then
    return "Bot"
  end

  return string.format("%d%%%%", math.floor((line / math.max(total, 1)) * 100))
end

local function visible_buffers(buffers, current, max_width)
  if #buffers == 0 then
    return 1, 0
  end

  local widths = {}
  local current_index = 1

  for i, bufnr in ipairs(buffers) do
    widths[i] = vim.fn.strdisplaywidth(file_icon(bufnr)) + vim.fn.strdisplaywidth(display_name(bufnr)) + 5
    if bufnr == current then
      current_index = i
    end
  end

  local start_idx = current_index
  local end_idx = current_index
  local used = widths[current_index]

  while true do
    local expanded = false

    if start_idx > 1 and used + widths[start_idx - 1] + 2 <= max_width then
      start_idx = start_idx - 1
      used = used + widths[start_idx] + 2
      expanded = true
    end

    if end_idx < #buffers and used + widths[end_idx + 1] + 2 <= max_width then
      end_idx = end_idx + 1
      used = used + widths[end_idx] + 2
      expanded = true
    end

    if not expanded then
      break
    end
  end

  return start_idx, end_idx
end

function M.next()
  cycle(1)
end

function M.prev()
  cycle(-1)
end

function M.close_current()
  local current = current_file_buffer()
  if current then
    vim.cmd("bdelete " .. current)
  end
end

function M.render(_, window)
  local current = vim.api.nvim_win_get_buf(window)
  local buffers

  if is_terminal_session_buffer(current) then
    buffers = listed_terminal_session_buffers()
  else
    buffers = listed_file_buffers()
  end

  if #buffers == 0 then
    return "%#StatusLine#"
  end

  if not is_terminal_session_buffer(current) and not is_file_buffer(current) then
    current = current_file_buffer()
  end

  current = current or buffers[1]

  local max_width = math.max(20, vim.api.nvim_win_get_width(window) - 12)
  local start_idx, end_idx = visible_buffers(buffers, current, max_width)
  local parts = {}

  table.insert(parts, "%#FooterTabsFill#")
  table.insert(parts, tree_prefix())

  if start_idx > 1 then
    table.insert(parts, "%#FooterTabsFill#  ")
    table.insert(parts, "%#FooterTab# … ")
  end

  for i = start_idx, end_idx do
    local bufnr = buffers[i]
    local active = bufnr == current
    local tab_hl = active and "%#FooterTabActive#" or "%#FooterTab#"
    local accent_hl = active and "%#FooterTabActiveAccent#" or "%#FooterTabEdge#"
    local icon, icon_hl = file_icon(bufnr)

    table.insert(parts, "%#FooterTabEdge# ")
    table.insert(parts, accent_hl .. "▎")
    table.insert(parts, tab_hl .. " ")
    if icon ~= "" then
      table.insert(parts, icon_hl and ("%#" .. icon_hl .. "#") or tab_hl)
      table.insert(parts, icon)
      table.insert(parts, tab_hl)
    end
    table.insert(parts, display_name(bufnr) .. " ")
    table.insert(parts, tab_hl .. " ")
  end

  if end_idx < #buffers then
    table.insert(parts, "%#FooterTab# … ")
  end

  local meta = {}
  local branch = current_branch(current)
  local encoding = vim.bo[current].fileencoding ~= "" and vim.bo[current].fileencoding or vim.o.encoding
  local filetype = vim.bo[current].filetype ~= "" and vim.bo[current].filetype or "text"

  if branch then
    table.insert(meta, " " .. branch)
  end

  table.insert(meta, mode_label())
  table.insert(meta, encoding)
  table.insert(meta, filetype)
  table.insert(meta, progress())
  table.insert(meta, location())

  table.insert(parts, "%#FooterTabsFill#%=")
  table.insert(parts, "%#FooterTabMeta#" .. table.concat(meta, "  "))
  return table.concat(parts, "")
end

return M
