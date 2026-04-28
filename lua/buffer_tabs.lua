local M = {}

local function is_file_buffer(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end

  local bo = vim.bo[bufnr]
  return bo.buflisted and bo.buftype == ""
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

local function current_listed_buffer()
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

  local current = current_listed_buffer() or buffers[1]
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

local function visible_buffers(buffers, current, max_width)
  if #buffers == 0 then
    return 1, 0
  end

  local widths = {}
  local current_index = 1

  for i, bufnr in ipairs(buffers) do
    widths[i] = vim.fn.strdisplaywidth(display_name(bufnr)) + 2
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
  local current = current_listed_buffer()
  if current then
    vim.cmd("bdelete " .. current)
  end
end

function M.render(_, window)
  local buffers = listed_file_buffers()
  if #buffers == 0 then
    return "%#StatusLine#"
  end

  local current = vim.api.nvim_win_get_buf(window)
  if not is_file_buffer(current) then
    current = current_listed_buffer()
  end

  local max_width = math.max(20, vim.api.nvim_win_get_width(window) - 12)
  local start_idx, end_idx = visible_buffers(buffers, current, max_width)
  local parts = {}

  table.insert(parts, "%#StatusLine#")

  if start_idx > 1 then
    table.insert(parts, "%#TabLine# … ")
  end

  for i = start_idx, end_idx do
    local bufnr = buffers[i]
    local hl = bufnr == current and "%#TabLineSel#" or "%#TabLine#"
    table.insert(parts, hl .. " " .. display_name(bufnr) .. " ")
  end

  if end_idx < #buffers then
    table.insert(parts, "%#TabLine# … ")
  end

  table.insert(parts, "%#StatusLine#%=")
  return table.concat(parts, "")
end

return M
