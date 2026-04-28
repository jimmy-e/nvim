local M = {}

local term_sessions = {}
local current_index = nil
local term_win = nil
local next_session_id = 1

local function split_height()
  return math.max(12, math.floor(vim.o.lines * 0.25))
end

local function is_valid_win()
  return term_win and vim.api.nvim_win_is_valid(term_win)
end

local function is_valid_buf(buf)
  return buf and vim.api.nvim_buf_is_valid(buf)
end

local function session_count()
  return #term_sessions
end

local function get_current_session()
  if not current_index then
    return nil
  end
  return term_sessions[current_index]
end

local function open_bottom_split()
  vim.cmd(("botright %dsplit"):format(split_height()))
  local win = vim.api.nvim_get_current_win()
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.wo[win].winfixheight = true
  return win
end

local function set_terminal_name(session)
  local label = ("Terminal %d"):format(session.id)
  if vim.api.nvim_buf_is_valid(session.buf) then
    vim.bo[session.buf].filetype = "terminal-session"
  end
  pcall(vim.api.nvim_buf_set_name, session.buf, label)
end

local function refresh_session_names()
  for _, session in ipairs(term_sessions) do
    set_terminal_name(session)
  end
end

local function show_session(session)
  if not session or not is_valid_buf(session.buf) then
    return
  end

  if not is_valid_win() then
    term_win = open_bottom_split()
  end

  vim.api.nvim_win_set_buf(term_win, session.buf)
  vim.api.nvim_set_current_win(term_win)
  vim.cmd("startinsert")
end

local function normalize_current_index()
  if session_count() == 0 then
    current_index = nil
    return
  end

  if not current_index or current_index < 1 then
    current_index = 1
    return
  end

  if current_index > session_count() then
    current_index = session_count()
  end
end

local function remove_session_by_buf(buf)
  for index, session in ipairs(term_sessions) do
    if session.buf == buf then
      table.remove(term_sessions, index)
      if current_index == index then
        if session_count() == 0 then
          current_index = nil
        elseif index > session_count() then
          current_index = session_count()
        else
          current_index = index
        end
      elseif current_index and current_index > index then
        current_index = current_index - 1
      end
      refresh_session_names()
      return
    end
  end
end

local function create_session()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].buflisted = true
  vim.b[buf].bottom_terminal_session = true

  local session = {
    id = next_session_id,
    buf = buf,
  }
  next_session_id = next_session_id + 1

  table.insert(term_sessions, session)
  current_index = session_count()
  set_terminal_name(session)

  show_session(session)
  vim.fn.termopen(vim.o.shell)

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    callback = function()
      remove_session_by_buf(buf)
      if is_valid_win() then
        local next_session = get_current_session()
        if next_session then
          vim.schedule(function()
            if is_valid_win() then
              show_session(next_session)
            end
          end)
        else
          term_win = nil
        end
      end
    end,
  })

  refresh_session_names()
  return session
end

local function cycle_session(step)
  if session_count() == 0 then
    create_session()
    return
  end

  normalize_current_index()
  current_index = ((current_index - 1 + step) % session_count()) + 1
  refresh_session_names()
  show_session(get_current_session())
end

function M.is_open()
  return is_valid_win()
end

function M.open()
  if is_valid_win() then
    return
  end

  if session_count() == 0 then
    create_session()
    return
  end

  normalize_current_index()
  refresh_session_names()
  show_session(get_current_session())
end

function M.close()
  if is_valid_win() then
    vim.api.nvim_win_close(term_win, false)
    term_win = nil
  end
end

function M.destroy()
  local session = get_current_session()
  if not session then
    M.close()
    return
  end

  if is_valid_win() and vim.api.nvim_win_get_buf(term_win) == session.buf then
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
  end

  if is_valid_buf(session.buf) then
    vim.api.nvim_buf_delete(session.buf, { force = true })
  end
end

function M.toggle()
  if is_valid_win() then
    M.close()
  else
    M.open()
  end
end

function M.new()
  create_session()
end

function M.next()
  cycle_session(1)
end

function M.prev()
  cycle_session(-1)
end

function M.session_count()
  return session_count()
end

vim.api.nvim_create_user_command("TerminalNew", function()
  M.new()
end, { desc = "Create a new terminal session" })

vim.api.nvim_create_user_command("TerminalNext", function()
  M.next()
end, { desc = "Switch to the next terminal session" })

vim.api.nvim_create_user_command("TerminalPrev", function()
  M.prev()
end, { desc = "Switch to the previous terminal session" })

return M
