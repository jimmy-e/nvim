local M = {}

local term_buf = nil
local term_win = nil

local function is_valid_buf()
  return term_buf and vim.api.nvim_buf_is_valid(term_buf)
end

local function is_valid_win()
  return term_win and vim.api.nvim_win_is_valid(term_win)
end

local function create_float_win(buf)
  local width = math.floor(vim.o.columns * 0.85)
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

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  return win
end

function M.is_open()
  return is_valid_win()
end

function M.open()
  if is_valid_win() then return end

  if is_valid_buf() then
    term_win = create_float_win(term_buf)
    vim.cmd("startinsert")
    return
  end

  term_buf = vim.api.nvim_create_buf(false, true)
  term_win = create_float_win(term_buf)
  vim.fn.termopen(vim.o.shell)
  vim.cmd("startinsert")

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = term_buf,
    callback = function()
      term_buf = nil
      term_win = nil
    end,
  })
end

function M.close()
  if is_valid_win() then
    vim.api.nvim_win_close(term_win, false)
    term_win = nil
  end
end

function M.destroy()
  if is_valid_win() then
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
  end
  if is_valid_buf() then
    vim.api.nvim_buf_delete(term_buf, { force = true })
    term_buf = nil
  end
end

function M.toggle()
  if is_valid_win() then
    M.close()
  else
    M.open()
  end
end

return M
